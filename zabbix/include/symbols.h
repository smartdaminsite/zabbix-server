/*
** Zabbix
** Copyright (C) 2001-2019 Zabbix SIA
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
**/

#ifndef ZABBIX_SYMBOLS_H
#define ZABBIX_SYMBOLS_H

#if defined(_WINDOWS)

/* some definitions which are not available on older MS Windows versions */
typedef enum {
	zbx_FileIdInfo	= 18	/* we need only one value, the rest of enumerated values are omitted here */
} ZBX_FILE_INFO_BY_HANDLE_CLASS;

typedef struct {
	ULONGLONG	LowPart;
	ULONGLONG	HighPart;
} ZBX_EXT_FILE_ID_128;

typedef struct {
	ULONGLONG		VolumeSerialNumber;
	ZBX_EXT_FILE_ID_128	FileId;
} ZBX_FILE_ID_INFO;

DWORD	(__stdcall *zbx_GetGuiResources)(HANDLE, DWORD);
BOOL	(__stdcall *zbx_GetProcessIoCounters)(HANDLE, PIO_COUNTERS);
BOOL	(__stdcall *zbx_GetPerformanceInfo)(PPERFORMANCE_INFORMATION, DWORD);
BOOL	(__stdcall *zbx_GlobalMemoryStatusEx)(LPMEMORYSTATUSEX);
BOOL	(__stdcall *zbx_GetFileInformationByHandleEx)(HANDLE, ZBX_FILE_INFO_BY_HANDLE_CLASS, LPVOID, DWORD);

void	import_symbols(void);

#else
#	define import_symbols()
#endif

#endif
