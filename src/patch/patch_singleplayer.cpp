#include "cbase.h"
#include <iostream>
#include <windows.h>
#include <Psapi.h>

struct Signature
{
	Signature(const char* Bytes, size_t Length) { this->Bytes = Bytes; this->Length = Length; }
	const char* Bytes;
	size_t Length;
};

#define SIGNATURE_WILDCARD 0x2A
#define SIGNATURE(x) Signature( #x, sizeof(#x) - 1 )

uintptr_t FindSignature(uintptr_t Start, uintptr_t Size, const Signature& Sig)
{
	uintptr_t End = Start + Size - Sig.Length;
	for (uintptr_t i = Start; i < End; i++)
	{
		bool found = true;
		for (uintptr_t j = 0; j < Sig.Length; j++)
			found &= Sig.Bytes[j] == SIGNATURE_WILDCARD || Sig.Bytes[j] == *(char*)(i + j);
		if (found)
			return i;
	}
	return 0;
}

void FindAllSignatures( uintptr_t Start, uintptr_t Size, const Signature& Sig, CUtlVector<uintptr_t>& List )
{
	uintptr_t End = Start + Size - Sig.Length;
	for (uintptr_t i = Start; i < End; i++)
	{
		bool found = true;
		for (uintptr_t j = 0; j < Sig.Length; j++)
			found &= Sig.Bytes[j] == SIGNATURE_WILDCARD || Sig.Bytes[j] == *(char*)(i + j);
		if (found)
		{
			List.AddToTail(i);
		}
	}
}

// maxplayers 1 fix by ficool2
void TFSOLO_Patch_Singleplayer()
{
	//DevMsg( "Patching engine...\n" );

	HMODULE engine = GetModuleHandle( "engine.dll" );

	MODULEINFO engineinfo = { 0 };
	GetModuleInformation( GetCurrentProcess(), engine, &engineinfo, sizeof( engineinfo ) );
	uintptr_t base = (uintptr_t)engineinfo.lpBaseOfDll;
	uintptr_t size = (uintptr_t)engineinfo.SizeOfImage;

	uintptr_t ptr1 = FindSignature( base, size,
	SIGNATURE(\x75\x4A\x48\x8B\x07) );
	uintptr_t ptr2 = FindSignature( base, size,
	SIGNATURE(\x48\x89\x5C\x24\x2A\x48\x89\x74\x24\x2A\x48\x89\x7C\x24\x2A\x55\x41\x54\x41\x55\x41\x56\x41\x57\x48\x8D\xAC\x24\x2A\x2A\x2A\x2A\xB8) );
	uintptr_t ptr3 = FindSignature( base, size,
	SIGNATURE(\x7E\x6D\xE8\x2A\x2A\x2A\x2A) );

	if ( !ptr1 || !ptr2 || !ptr3 )
	{
		DevWarning( "Engine Patch: Failed to find signature\n" );
		return;
	}
	
	// use MP buffer size
	// jnz -> jmp
	DWORD protect1;
	if ( VirtualProtect( (void*)ptr1, 1, PAGE_READWRITE, &protect1 ) )
	{
		byte payload[] = { 0xEB };
		memcpy( (void*)ptr1, payload, 1 );
		VirtualProtect( (void*)ptr1, 1, protect1, &protect1 );
	}

	// fix signed 32bit comparison
	// mov r10d, 0FFFFFFFFh
	// ->
	// xor r10, r10
	// not r10
	CUtlVector<uintptr_t> sequences;
	FindAllSignatures( ptr2, 0x4A2,
		SIGNATURE(\x41\xBA\xFF\xFF\xFF\xFF), sequences );
	if ( sequences.Count() == 5 )
	{
		byte payload[] = { 0x4d, 0x31, 0xd2, 0x49, 0xf7, 0xd2 };
		FOR_EACH_VEC( sequences, i )
		{
			uintptr_t ptr_s = sequences[i];
			DWORD protect;
			if ( VirtualProtect( (void*)ptr_s, 6, PAGE_READWRITE, &protect ) )
			{
				memcpy( (void*)ptr_s, payload, 6 );
				VirtualProtect( (void*)ptr_s, 6, protect, &protect );
			}
		}
	}
	else
	{
		DevWarning( "Engine Patch: Failed to find signature 2\n" );
	}

	// keep steam connected in singleplayer for GC
	// jle -> nop
	DWORD protect3;
	if ( VirtualProtect( (void*)ptr3, 2, PAGE_READWRITE, &protect3 ) )
	{
		byte payload[] = { 0x66,  0x90 };
		memcpy( (void*)ptr3, payload, 2 );
		VirtualProtect( (void*)ptr3, 2, protect3, &protect3 );
	}
}