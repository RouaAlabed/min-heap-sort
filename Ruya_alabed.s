	AREA min_heap_sort, CODE, READWRITE
	ENTRY
	EXPORT main
main	PROC
	LDR R0, =arr			; dizi adresi
	LDR R1, [R0], #4 		; dizi boyutu arr[0], r0 + 4 => arr[1] -> asil dizi adresi
	MOV R2, #0				; i -> d�g�m�n indis degeri
	
	MOV R10, R0				; dizi adresini sakla, ��nk� siralama prosed�r� adresi ve boyutu degistirir
	MOV R11, R1				; dizi boyutunu sakla, ��nk� siralama prosed�r� adresi ve boyutu degistirir
	BL sort					; siralama prosed�r�n� �agir
	
	; orijinal kayitlara geri d�n
	MOV R0, R10
	MOV R1, R11
	
	MOV R4, #3
	BL find					; 3'�n min heap'te olup olmadigini kontrol et
	
	MOV R4, #12
	BL find					; 12'nin min heap'te olup olmadigini kontrol et

dead						; sonra �l� d�ng�ye gidip bitir
	B dead

; diziyi min heap algoritmasini kullanarak siralayan prosed�r
sort PROC
	PUSH {LR}			; LR'yi it
	MOV R9, #0			; sort_for_i = 0
	MOV R12, R1			; sort_for_n = boyut (sort_for_n yerel bir parametredir)
sort_for				; for d�ng�s�n� baslat
	CMP R9, R12			; sort_for_i ve dizi boyutunu karsilastir
	BGE sort_end_for	; eger (sort_for_i >= dizi boyutu) siralama i�in d�ng�y� bitir
	BL build			; degilse build prosed�r�n� �agir
	ADD R0, R0, #4		; arr + 1 -> dizi adresini degistir (int = 4 byte)
	SUB R1, R1, #1		; boyut - 1 -> dizi boyutunu azalt
	ADD R9, R9, #1		; sort_for_i++
	B sort_for			; siralama i�in d�ng�ye devam et
sort_end_for
	POP {PC}			; PC'yi geri al
	ENDP

; min heap'i olusturan prosed�r
build PROC
	PUSH {LR}
	MOV R8, R1, LSR #1		; n / 2 (n dizinin boyutudur)
	SUB R8, R8, #1			; indeks = n / 2 - 1 -> k�k�n indeksi
	
for							; for d�ng�s�n� baslat
	CMP R8, #0				; indeksi ve sifiri karsilastir
	BLT end_for				; eger (indeks < sifir) d�ng�y� bitir
	MOV R2, R8				; degilse i = indeks
	BL heapify				; heapify prosed�r�n� �agir
	SUB R8, R8, #1			; indeks--
	B for					; for d�ng�s�ne devam et
end_for
	POP {PC}
	ENDP

; i k�k d�g�m olan bir alt agaci heapify eden prosed�r, i dizide bir indekstir
heapify PROC
	PUSH {LR}
								; R3 en k���k
recursive 
	MOV R3, R2					; en k���g� baslat = i
	MOV R4, R2, LSL #1			; sol = 2 * i
	ADD R4, R4, #1				; sol = 2 * i + 1
	MOV R5, R2, LSL #1			; sag = 2 * i
	ADD R5, R5, #2				; sag = 2 * i + 2
	
	CMP R4, R1					; sol ve boyutu karsilastir
	BGE end_left_control		; eger (sol >= boyut) sol kontrol� bitir
	LDR R6, [R0, R4, LSL #2]	; degilse R6 = arr[sol]
	LDR R7, [R0, R3, LSL #2]	; R7 = arr[en k���k]
	CMP R6, R7					; arr[sol] ve arr[en k���k] karsilastir
	BGE end_left_control		; eger (arr[sol] >= arr[en k���k]) sol kontrol� bitir
	MOV R3, R4					; degilse en k���k = sol
end_left_control

	
	CMP R5, R1					; sag ve boyutu karsilastir
	BGE end_right_control		; eger (sag >= boyut) sag kontrol� bitir
	LDR R6, [R0, R5, LSL #2]	; degilse R6 = arr[sag]
	LDR R7, [R0, R3, LSL #2]	; R7 = arr[en k���k]
	CMP R6, R7					; arr[sag] ve arr[en k���k] karsilastir
	BGE end_right_control		; eger (arr[sag] >= arr[en k���k]) sag kontrol� bitir
	MOV R3, R5					; degilse en k���k = sag
end_right_control

	CMP R3, R2					; en k���k ve i karsilastir
	BEQ end_if					; eger (en k���k == i) if'i bitir, degilse degistir
	LDR R6, [R0, R2, LSL #2]	; temp = arr[i]
	LDR R7, [R0, R3, LSL #2]	; arr[en k���k]
	STR R7, [R0, R2, LSL #2]	; arr[i] = arr[en k���k]
	STR R6, [R0, R3, LSL #2]	; arr[en k���k] = temp
	MOV R2, R3					; i = en k���k
	B recursive
end_if
	POP {PC}
	ENDP

; min heap'te elemani (R4) bulan prosed�r
; eger eleman bulunursa 1 d�nd�r (R3 = 1), degilse 0 d�nd�r (R3 = 0)
find PROC
	PUSH {LR}
	MOV R2, #0	; i = 0 -> find_loop i�in indeks
	MOV R3, #0	; false
find_loop
	CMP R2, R1					; indeks ve dizi boyutunu karsilastir
	BGE find_end_loop			; eger (indeks >= boyut) d�ng�y� bitir
	LDR R5, [R0, R2, LSL #2]	; R5 = arr[i]
	CMP R4, R5
	BEQ founded					; eger (R4 == R5)
	ADD R2, R2, #1				; i++
	B find_loop					; degilse d�ng�ye devam et
founded
	MOV R3, #1	; true
find_end_loop
	POP {PC}
	ENDP
		
; bir dizi tanimla
arr
	DCD 5, 4, 6, 3, 2, 9, -2147483648; arr[0] -> boyut, arr = [1...boyut]
	END
