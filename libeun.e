-- Copyright (c) 2020 James Cook

-- Compiles into a dll

-- Can be used by either 32-bit or 64-bit "euc" to make it into a DLL:

-- Example for Watcom 32-bit:
-- C:\> euc -o libmyeun.dll -strict -dll -wat -keep libeun.e
-- Example for GCC:
-- C:\> euc -o libmyeun.dll -strict -dll -gcc -keep libeun.e

-- NOTE: Don't mix ids of different types.

include allocate.e
include dll.e
include std/pretty.e
include classfile.e as pointers
include classfile.e as numArray
include classfile.e as eun
include classfile.e as complex
include classfile.e as matrix
include myeunumber.e as my

public function Version()
	return 50 -- Need to debug with Wrapper "Stub" (myeun.h)
end function

public function UsingHowManyBits()
ifdef BITS64 then
	return 64
elsedef
	return 32
end ifdef
end function
-- Pointers:

public function RegisterPointer(integer low, integer high)
-- Register your client application's pointer (in client/server model), so the DLL can use it.
-- Takes two 16-bit unsigned integers (low and high), to represent a complete 32-bit unsigned integer
-- returned as an id to be used as a pointer in other functions
ifdef BITS64 then
	return pointers:new_object_from_data(and_bits(low, #FFFFFFFF) + and_bits(high, #FFFFFFFF) * #100000000)
elsedef
	return pointers:new_object_from_data(and_bits(low, #FFFF) + and_bits(high, #FFFF) * #10000)
end ifdef
end function

public procedure UnRegisterPointer(integer id)
	pointers:delete_object(id)
end procedure

public function NewPointer()
-- In case you don't want to register one of your pointers, it will allocate one of its own for you (server-side).
ifdef BITS64 then
	atom pointer = allocate_data(8)
	poke8(pointer, 0)
elsedef
	atom pointer = allocate_data(4)
	poke4(pointer, 0)
end ifdef
	return pointers:new_object_from_data(pointer)
end function

public procedure CopyPointerToAddress(integer dstId, integer srcId)
ifdef BITS64 then
	poke8(pointers:get_data_from_object(dstId), pointers:get_data_from_object(srcId))
elsedef
	poke4(pointers:get_data_from_object(dstId), pointers:get_data_from_object(srcId))
end ifdef
end procedure

public procedure FreePointer(integer id)
-- Free one of the DLL's pointers and unregister it.
	atom ma = pointers:get_data_from_object(id)
	free(ma)
	-- It points to nothing now, so un-register pointer.
	UnRegisterPointer(id)
end procedure

-- NumArrays:

public function NewNumArrayFromCIntArray(integer id_of_ma, integer how_many)
ifdef BITS64 then
	sequence num = peek8s({pointers:get_data_from_object(id_of_ma), how_many})
elsedef
	sequence num = peek4s({pointers:get_data_from_object(id_of_ma), how_many})
end ifdef
	return numArray:new_object_from_data(num)
end function

public function NewCIntArrayFromNumArray(integer pointer_dstId, integer idOfNumArray)
	sequence num = numArray:get_data_from_object(idOfNumArray)
ifdef BITS64 then
	atom ma = allocate_data(length(num) * 8) -- 64bit integers are 8 bytes in size
	poke8(ma, num)
	poke8(pointers:get_data_from_object(pointer_dstId), ma)
elsedef
	atom ma = allocate_data(length(num) * 4) -- 32bit integers are 4 bytes in size
	poke4(ma, num)
	poke4(pointers:get_data_from_object(pointer_dstId), ma)
end ifdef
	return length(num)
end function

public procedure FreeNewCIntArrayPointer(integer pointer_dstId)
ifdef BITS64 then
	atom ma = peek8u(pointers:get_data_from_object(pointer_dstId))
elsedef
	atom ma = peek4u(pointers:get_data_from_object(pointer_dstId))
end ifdef
	free(ma)
end procedure

public procedure DeleteNumArray(integer id)
	numArray:delete_object(id)
end procedure

public function CloneNumArray(integer id)
	return numArray:clone_object(id)
end function

public procedure CopyNumArray(integer dstId, integer srcId)
	numArray:replace_object(dstId, numArray:get_data_from_object(srcId))
end procedure

public function GetLengthOfNumArray(integer id)
	return length(numArray:get_data_from_object(id))
end function

-- Eun's:

function NewFromEun(Eun n1)
	return eun:new_object_from_data(n1)
end function

public function NewEun(integer arrayid, integer exp, integer radix, integer targetLength, Bool sign_of_exp)
	return NewFromEun(my:NewEun(numArray:get_data_from_object(arrayid), iff(sign_of_exp, -exp, exp), radix, targetLength))
end function

public procedure DeleteEun(integer id)
	eun:delete_object(id)
end procedure

function GetEun(integer id)
	return eun:get_data_from_object(id)
end function

public procedure StoreEun(integer id_dst, integer id_src) -- move operator
	eun:store_object(id_dst, id_src)
end procedure

public function CloneEun(integer id)
	return eun:clone_object(id)
end function

-- Access Data Members:
public function GetEunArray(integer id)
	sequence n1 = GetEun(id)
	integer arrayId = numArray:new_object_from_data(n1[1])
	return arrayId
end function

public procedure GetEunExponent(integer dstptrId, integer eunId)
	sequence n1 = GetEun(eunId)
ifdef BITS64 then
	poke8(pointers:get_data_from_object(dstptrId), n1[2])
elsedef
	poke4(pointers:get_data_from_object(dstptrId), n1[2])
end ifdef
end procedure

public function GetEunRadix(integer id)
	sequence n1 = GetEun(id)
	return n1[3]
end function

public function GetEunTargetLength(integer id)
	sequence n1 = GetEun(id)
	return n1[4]
end function

public procedure GetEunFlags(integer dstptrId, integer eunId) -- get rounding information
	sequence n1 = GetEun(eunId)
ifdef BITS64 then
	poke8(pointers:get_data_from_object(dstptrId), n1[5])
elsedef
	poke4(pointers:get_data_from_object(dstptrId), n1[5])
end ifdef
end procedure

public function EunToCString(integer id)
	sequence st = my:ToString(GetEun(id))
	atom ma = allocate_string(st)
	return pointers:new_object_from_data(ma)
	-- be sure to call "FreePointer()" after you are done with it
end function

public function CStringToEun(integer id_ma, integer radix, integer targetLength)
	sequence st = peek_string(pointers:get_data_from_object(id_ma))
	return my:ToEun(st, radix, targetLength)
end function

function match_replace(object needle, sequence haystack, object replacement, 
			integer max=0)
	integer posn
	integer needle_len
	integer replacement_len
	integer scan_from
	integer cnt
	
	
	if max < 0 then
		return haystack
	end if
	
	cnt = length(haystack)
	if max != 0 then
		cnt = max
	end if
	
	if atom(needle) then
		needle = {needle}
	end if
	if atom(replacement) then
		replacement = {replacement}
	end if

	needle_len = length(needle) - 1
	replacement_len = length(replacement)

	scan_from = 1
	while posn with entry do
		haystack = replace(haystack, replacement, posn, posn + needle_len)

		cnt -= 1
		if cnt = 0 then
			exit
		end if
		scan_from = posn + replacement_len
	entry
		posn = match(needle, haystack, scan_from)
	end while

	return haystack
end function


public function EunPrintToCString(integer x)
	sequence st = pretty_sprint(GetEun(x), {0, 8}) -- 8 spaces for indent
	atom ma
	st = match_replace("\n", st, "\r\n")
	ma = allocate_string(st)
	return pointers:new_object_from_data(ma)
	-- be sure to call "FreePointer()" after you are done with it
end function

-- Complex's:

function NewFromComplex(Complex c1)
	return complex:new_object_from_data(c1)
end function

public function NewComplex(integer realEunId, integer imaginaryEunId)
	return NewFromComplex(my:NewComplex(GetEun(realEunId), GetEun(imaginaryEunId)))
end function

public procedure DeleteComplex(integer id)
	complex:delete_object(id)
end procedure

function GetComplex(integer id)
	return complex:get_data_from_object(id)
end function

public procedure StoreComplex(integer id_dst, integer id_src)
	complex:store_object(id_dst, id_src)
end procedure

public function CloneComplex(integer id)
	return complex:clone_object(id)
end function

-- Access Data Members:

public function GetRealEun(integer complexId)
	sequence s = GetComplex(complexId)
	return NewFromEun(s[my:REAL])
end function

public function GetImaginaryEun(integer complexId)
	sequence s = GetComplex(complexId)
	return NewFromEun(s[my:IMAG])
end function

-- MyEuNumber functions:

-- list functions to export.

public function GetVersion()
	return my:GetVersion()
end function

public function GetDivideByZeroFlag()
	return my:GetDivideByZeroFlag()
end function

public procedure SetDefaultTargetLength(integer i)
	my:SetDefaultTargetLength(i)
end procedure

public function GetDefaultTargetLength()
	return my:GetDefaultTargetLength()
end function

public procedure SetDefaultRadix(integer i)
	my:SetDefaultRadix(i)
end procedure

public function GetDefaultRadix()
	return my:GetDefaultRadix()
end function

public procedure SetAdjustRound(integer i)
	my:SetAdjustRound(i)
end procedure

public function GetAdjustRound()
	return my:GetAdjustRound()
end function

public procedure SetCalcSpeed(integer ptrToDblId)
	atom speed = float64_to_atom(peek({pointers:get_data_from_object(ptrToDblId), 8}))
	my:SetCalcSpeed(speed)
end procedure

public procedure GetCalcSpeed(integer dstptrToDblId)
	sequence s = atom_to_float64(my:GetCalcSpeed())
	poke(pointers:get_data_from_object(dstptrToDblId), s)
end procedure

public procedure SetRound(integer i)
	my:SetRound(i)
end procedure

public function GetRound()
	return my:GetRound()
end function

public procedure SetRoundToNearestOption(integer boolean_value_num)
	my:SetRoundToNearestOption(boolean_value_num)
end procedure

public function GetRoundToNearestOption()
	return my:GetRoundToNearestOption()
end function

Bool local_sign = 0

public function GetSignOfMoreAccuracy()
	return local_sign
end function

public procedure SetMultiplicativeInverseMoreAccuracy(integer i, integer sign)
	if sign then
		i = -1
	end if
	my:SetMultiplicativeInverseMoreAccuracy(i)
end procedure

public function GetMultiplicativeInverseMoreAccuracy()
	integer a = my:GetMultiplicativeInverseMoreAccuracy()
	local_sign = a < 0
	if local_sign then
		return 0
	else
		return a
	end if
end function

public procedure SetNthRootMoreAccuracy(integer i, integer sign)
	if sign then
		i = -1
	end if
	my:SetNthRootMoreAccuracy(i)
end procedure

public function GetNthRootMoreAccuracy()
	integer a = my:GetNthRootMoreAccuracy()
	local_sign = a < 0
	if local_sign then
		return 0
	else
		return a
	end if
end function

public procedure SetExpMoreAccuracy(integer i, integer sign)
	if sign then
		i = -1
	end if
	my:SetExpMoreAccuracy(i)
end procedure

public function GetExpMoreAccuracy()
	integer a = my:GetExpMoreAccuracy()
	local_sign = a < 0
	if local_sign then
		return 0
	else
		return a
	end if
end function

public procedure SetLogMoreAccuracy(integer i, integer sign)
	if sign then
		i = -1
	end if
	my:SetLogMoreAccuracy(i)
end procedure

public function GetLogMoreAccuracy()
	integer a = my:GetLogMoreAccuracy()
	local_sign = a < 0
	if local_sign then
		return 0
	else
		return a
	end if
end function

public procedure SetSinMoreAccuracy(integer i, integer sign)
	if sign then
		i = -1
	end if
	my:SetSinMoreAccuracy(i)
end procedure

public function GetSinMoreAccuracy()
	integer a = my:GetSinMoreAccuracy()
	local_sign = a < 0
	if local_sign then
		return 0
	else
		return a
	end if
end function

public procedure SetCosMoreAccuracy(integer i, integer sign)
	if sign then
		i = -1
	end if
	my:SetCosMoreAccuracy(i)
end procedure

public function GetCosMoreAccuracy()
	integer a = my:GetCosMoreAccuracy()
	local_sign = a < 0
	if local_sign then
		return 0
	else
		return a
	end if
end function

public procedure SetArcSinMoreAccuracy(integer i, integer sign)
	if sign then
		i = -1
	end if
	my:SetArcSinMoreAccuracy(i)
end procedure

public function GetArcSinMoreAccuracy()
	integer a = my:GetArcSinMoreAccuracy()
	local_sign = a < 0
	if local_sign then
		return 0
	else
		return a
	end if
end function

public procedure SetArcTanMoreAccuracy(integer i, integer sign)
	if sign then
		i = -1
	end if
	my:SetArcTanMoreAccuracy(i)
end procedure

public function GetArcTanMoreAccuracy()
	integer a = my:GetArcTanMoreAccuracy()
	local_sign = a < 0
	if local_sign then
		return 0
	else
		return a
	end if
end function

-- MyEuNumber Functions:

public function IsIntegerOdd(integer i)
	return my:IsIntegerOdd(i)
end function

public function IsIntegerEven(integer i)
	return my:IsIntegerEven(i)
end function

public function IsArrayNegative(integer numArrayId)
	return my:IsNegative(numArray:get_data_from_object(numArrayId))
end function

public function RangeEqual(integer a, integer b, integer start, integer stop)
	return my:RangeEqual(numArray:get_data_from_object(a), numArray:get_data_from_object(b), start, stop)
end function

public function Borrow(integer num, integer radix)
	return numArray:new_object_from_data(my:Borrow(numArray:get_data_from_object(num), radix))
end function

public function NegativeBorrow(integer num, integer radix)
	return numArray:new_object_from_data(my:NegativeBorrow(numArray:get_data_from_object(num), radix))
end function

public function Carry(integer num, integer radix)
	return numArray:new_object_from_data(my:Carry(numArray:get_data_from_object(num), radix))
end function

public function NegativeCarry(integer num, integer radix)
	return numArray:new_object_from_data(my:NegativeCarry(numArray:get_data_from_object(num), radix))
end function

public function Add(integer n1, integer n2)
	return numArray:new_object_from_data(my:Add(numArray:get_data_from_object(n1), numArray:get_data_from_object(n2)))
end function

public function ConvertRadix(integer num, integer fromRadix, integer toRadix)
	return numArray:new_object_from_data(my:ConvertRadix(numArray:get_data_from_object(num), fromRadix, toRadix))
end function

public function Multiply(integer n1, integer n2)
	return numArray:new_object_from_data(my:Multiply(numArray:get_data_from_object(n1), numArray:get_data_from_object(n2)))
end function

public function Square(integer n1)
	return numArray:new_object_from_data(my:Square(numArray:get_data_from_object(n1)))
end function

public function IsNegative(integer numId)
	return my:IsNegative(numArray:get_data_from_object(numId))
end function

public function Negate(integer num)
	return numArray:new_object_from_data(my:Negate(numArray:get_data_from_object(num)))
end function

public function AbsoluteValue(integer num)
	return numArray:new_object_from_data(my:AbsoluteValue(numArray:get_data_from_object(num)))
end function

public function Subtract(integer num, integer radix)
	return numArray:new_object_from_data(my:Subtract(numArray:get_data_from_object(num), radix))
end function

public function TrimLeadingZeros(integer num)
	return numArray:new_object_from_data(my:TrimLeadingZeros(numArray:get_data_from_object(num)))
end function

public function TrimTrailingZeros(integer num)
	return numArray:new_object_from_data(my:TrimTrailingZeros(numArray:get_data_from_object(num)))
end function

public function AdjustRound(integer num, integer exponent, integer targetLength, integer radix)
	return NewFromEun(my:AdjustRound(numArray:get_data_from_object(num), exponent, targetLength, radix))
end function

public function MultiplyExp(integer n1, integer exp1, integer n2, integer exp2, integer targetLength, integer radix)
	return NewFromEun(my:MultiplyExp(numArray:get_data_from_object(n1), exp1, numArray:get_data_from_object(n2), exp2, targetLength, radix))
end function

public function SquareExp(integer n1, integer exp1, integer targetLength, integer radix)
	return NewFromEun(my:SquareExp(numArray:get_data_from_object(n1), exp1, targetLength, radix))
end function

public function AddExp(integer n1, integer exp1, integer n2, integer exp2, integer targetLength, integer radix)
	return NewFromEun(my:AddExp(numArray:get_data_from_object(n1), exp1, numArray:get_data_from_object(n2), exp2, targetLength, radix))
end function

public function SubtractExp(integer n1, integer exp1, integer n2, integer exp2, integer targetLength, integer radix)
	return NewFromEun(my:SubtractExp(numArray:get_data_from_object(n1), exp1, numArray:get_data_from_object(n2), exp2, targetLength, radix))
end function

public function MultiplicativeInverseExp(integer den1, integer exp1, integer targetLength, integer radix)
	return NewFromEun(my:MultiplicativeInverseExp(numArray:get_data_from_object(den1), exp1, targetLength, radix))
end function

public function DivideExp(integer num1, integer exp1, integer den2, integer exp2, integer targetLength, integer radix)
	return NewFromEun(my:DivideExp(numArray:get_data_from_object(num1), exp1, numArray:get_data_from_object(den2), exp2, targetLength, radix))
end function

public function ConvertExp(integer n1, integer exp1, integer targetLength, integer fromRadix, integer toRadix)
	return NewFromEun(my:ConvertExp(numArray:get_data_from_object(n1), exp1, targetLength, fromRadix, toRadix))
end function

-- Begin Eun:

public function EunAdjustRound(integer n1, integer adjustBy)
	return NewFromEun(my:EunAdjustRound(GetEun(n1), adjustBy))
end function

public function EunMultiply(integer n1, integer n2)
	return NewFromEun(my:EunMultiply(GetEun(n1), GetEun(n2)))
end function

public function EunSquare(integer n1)
	return NewFromEun(my:EunSquare(GetEun(n1)))
end function

public function EunAdd(integer n1, integer n2)
	return NewFromEun(my:EunAdd(GetEun(n1), GetEun(n2)))
end function

public function EunNegate(integer n1)
	return NewFromEun(my:EunNegate(GetEun(n1)))
end function

public function EunAbsoluteValue(integer n1)
	return NewFromEun(my:EunAbsoluteValue(GetEun(n1)))
end function

public function EunSubtract(integer n1, integer n2)
	return NewFromEun(my:EunSubtract(GetEun(n1), GetEun(n2)))
end function

public function EunMultiplicativeInverse(integer n1)
	return NewFromEun(my:EunMultiplicativeInverse(GetEun(n1)))
end function

public function EunDivide(integer n1, integer n2)
	return NewFromEun(my:EunDivide(GetEun(n1), GetEun(n2)))
end function

public function EunConvert(integer n1, integer toRadix, integer targetLength)
	return NewFromEun(my:EunConvert(GetEun(n1), toRadix, targetLength))
end function

public function CompareExp(sequence n1, integer exp1, sequence n2, integer exp2)
	return my:CompareExp(numArray:get_data_from_object(n1), exp1, numArray:get_data_from_object(n2), exp2) + 1
end function

public function GetEqualLength()
	return my:GetEqualLength()
end function

public function EunCompare(integer n1, integer n2)
	return my:EunCompare(GetEun(n1), GetEun(n2)) + 1
end function

public function EunReverse(integer n1) -- reverse endian
	return NewFromEun(my:EunReverse(GetEun(n1)))
end function

public function EunFracPart(integer n1)
	return NewFromEun(my:EunFracPart(GetEun(n1)))
end function

public function EunIntPart(integer n1)
	return NewFromEun(my:EunIntPart(GetEun(n1)))
end function

public function EunRoundSig(integer n1, integer sigDigits)
	return NewFromEun(my:EunRoundSig(GetEun(n1), sigDigits))
end function

public function EunRoundToInt(integer n1) -- Round to nearest integer
	return NewFromEun(my:EunRoundToInt(GetEun(n1)))
end function

public function EunCombInt(integer n1, integer adjustBy, integer up) -- default value for up is zero "0"
	return NewFromEun(my:EunCombInt(GetEun(n1), adjustBy, up))
end function

public procedure EunModf(integer dstEunIdIntPart, integer dstEunIdFracPart, integer numId)
-- EunModf(Eun fp) -- similar to C's "modf()"
	sequence s = my:EunModf(GetEun(numId))
	eun:replace_object(dstEunIdIntPart, s[1])
	eun:replace_object(dstEunIdFracPart, s[2])
end procedure

public procedure EunfDiv(integer dstEunIdQuot, integer dstEunIdRem, integer numId, integer denId)
-- EunfDiv(Eun num, Eun den) -- similar to C's "div()"
	sequence s = my:EunfDiv(GetEun(numId), GetEun(denId))
	eun:replace_object(dstEunIdQuot, s[1])
	eun:replace_object(dstEunIdRem, s[2])
end procedure

public function EunfMod(integer numId, integer denId)
-- EunfMod(Eun num, Eun den) -- similar to C's "fmod()", just the "mod" or remainder
	return NewFromEun(my:EunfMod(GetEun(numId), GetEun(denId)))
end function

-- numio.e functions:

public function EunToMemory(integer n1)
	-- returns id to a pointer
	-- remember to use "FreePointer()" to deallocate it.
	atom ma = my:ToMemory(GetEun(n1))
	return pointers:new_object_from_data(ma)
end function

public function FromMemoryToEun(integer pointer_id)
	sequence n1 = my:FromMemoryToEun(pointers:get_data_from_object(pointer_id))
	return NewFromEun(n1)
end function

-- NthRoot functions:

public procedure SetRealMode(integer i)
	my:SetRealMode(i)
end procedure

public function GetRealMode()
	return my:GetRealMode()
end function

public function EunIntPower(integer toPower, integer id)
	sequence n1 = GetEun(id)
	return NewFromEun(my:IntPowerExp(toPower, n1[1], n1[2], n1[3], n1[4]))
end function

public function NthRootExp(PositiveScalar n, integer x1, integer x1Exp, integer guess, integer guessExp, integer targetLength, integer radix)
	sequence n1, n2
	n1 = numArray:get_data_from_object(x1)
	n2 = numArray:get_data_from_object(guess)
	return NewFromEun(my:NthRootExp(n, n1, x1Exp, n2, guessExp, targetLength, radix))
end function

public function EunNthRoot(integer dstEunId, integer dstExtraEunId, integer n, integer n1)
	-- returns if result is imaginary, or multiplied by sqrt(-1)
	sequence s = my:EunNthRoot(n, GetEun(n1))
	if length(s) = 3 then
		eun:replace_object(dstEunId, s[2])
		eun:replace_object(dstExtraEunId, s[3])
		return s[1]
	else
		eun:replace_object(dstEunId, s)
		if dstExtraEunId then
			eun:replace_object(dstExtraEunId, s)
		end if
		return 0
	end if
end function

public function EunSquareRoot(integer dstEunId, integer dstExtraEunId, integer n1)
	return EunNthRoot(dstEunId, dstExtraEunId, 2, n1)
end function

public procedure EunCubeRoot(integer dstEunId, integer n1)
	-- results are never imaginary for "EunCubeRoot()"
	-- return result in "dstEunId" just like the other NthRoot functions.
	-- treat function as procedure:
	if EunNthRoot(dstEunId, NULL, 3, n1) then
	end if
end procedure

-- mymath.e functions:

public function EunArcTan(integer n1)
	return NewFromEun(my:EunArcTan(GetEun(n1)))
end function

public function GetQuarterPI(integer targetLength, integer radix)
	return NewFromEun(my:GetQuarterPI(targetLength, radix))
end function
public function GetHalfPI(integer targetLength = defaultTargetLength, integer radix = defaultRadix)
	return NewFromEun(my:GetHalfPI(targetLength, radix))
end function
public function GetPI(integer targetLength = defaultTargetLength, integer radix = defaultRadix)
	return NewFromEun(my:GetPI(targetLength, radix))
end function
public function GetE(integer targetLength, integer radix)
	return NewFromEun(my:GetE(targetLength, radix))
end function

public function EunExp(integer n1)
	-- ExpExp() doesn't like large numbers.
	-- so, factor
	return NewFromEun(my:EunExp(GetEun(n1)))
end function

public function EunExpFast(integer numerator, integer denominator)
	return NewFromEun(my:EunExpFast(GetEun(numerator), GetEun(denominator)))
end function

public function EunLog(integer n1)
	sequence s = my:EunLog(GetEun(n1))
	if length(s) != 2 then
		return NewFromEun(s)
	end if
	return 0 -- not doing complex mode, yet.
end function

-- Begin Trig Functions:

-- They all use Radians.

public function EunRadiansToDegrees(integer n1)
	return NewFromEun(my:EunRadiansToDegrees(GetEun(n1)))
end function
public function EunDegreesToRadians(integer n1)
	return NewFromEun(my:EunDegreesToRadians(GetEun(n1)))
end function


public function EunSin(integer n1)
	return NewFromEun(my:EunSin(GetEun(n1)))
end function
public function EunCos(integer n1)
	return NewFromEun(my:EunCos(GetEun(n1)))
end function
public function EunTan(integer n1)
	return NewFromEun(my:EunTan(GetEun(n1)))
end function

public function EunCsc(integer n1)
	return NewFromEun(my:EunCsc(GetEun(n1)))
end function
public function EunSec(integer n1)
	return NewFromEun(my:EunSec(GetEun(n1)))
end function
public function EunCot(integer n1)
	return NewFromEun(my:EunCot(GetEun(n1)))
end function

public function EunArcSin(integer n1)
	return NewFromEun(my:EunArcSin(GetEun(n1)))
end function
public function EunArcCos(integer n1)
	return NewFromEun(my:EunArcCos(GetEun(n1)))
end function

-- EunArcTan already defined, see above.

public function EunArcCsc(integer n1)
	return NewFromEun(my:EunArcCsc(GetEun(n1)))
end function
public function EunArcSec(integer n1)
	return NewFromEun(my:EunArcSec(GetEun(n1)))
end function
public function EunArcCot(integer n1)
	return NewFromEun(my:EunArcCot(GetEun(n1)))
end function

-- Hyperbolic functions:

public function EunSinh(integer n1)
	return NewFromEun(my:EunSinh(GetEun(n1)))
end function
public function EunCosh(integer n1)
	return NewFromEun(my:EunCosh(GetEun(n1)))
end function
public function EunTanh(integer n1)
	return NewFromEun(my:EunTanh(GetEun(n1)))
end function

public function EunCsch(integer n1)
	return NewFromEun(my:EunCsch(GetEun(n1)))
end function
public function EunSech(integer n1)
	return NewFromEun(my:EunSech(GetEun(n1)))
end function
public function EunCoth(integer n1)
	return NewFromEun(my:EunCoth(GetEun(n1)))
end function

public function EunArcSinh(integer n1)
	return NewFromEun(my:EunArcSinh(GetEun(n1)))
end function
public function EunArcCosh(integer n1)
	return NewFromEun(my:EunArcCosh(GetEun(n1)))
end function
public function EunArcTanh(integer n1)
	return NewFromEun(my:EunArcTanh(GetEun(n1)))
end function

public function EunArcCsch(integer n1)
	return NewFromEun(my:EunArcCsch(GetEun(n1)))
end function
public function EunArcSech(integer n1)
	return NewFromEun(my:EunArcSech(GetEun(n1)))
end function
public function EunArcCoth(integer n1)
	return NewFromEun(my:EunArcCoth(GetEun(n1)))
end function

-- Triangulation using two (2) points

public procedure EunTriangulation(integer eun_dst1, integer eun_dst2, integer eun_a, integer eun_b, integer eun_c, integer whichOnes)
	object ret
	ret = my:EunTriangulation(GetEun(eun_a), GetEun(eun_b), GetEun(eun_c), whichOnes)
	if and_bits(whichOnes, 1) then
		eun:replace_object(eun_dst1, ret[1])
	end if
	if and_bits(whichOnes, 2) then
		eun:replace_object(eun_dst2, ret[2])
	end if
end procedure

-- euroots.e:

-- Find the roots of the equation, (a callback function)

public function GetDelta() -- returns positive value of delta (which is negative)
	return - my:delta[2]
end function

public procedure SetDelta(integer i) -- positive number to negate
	-- "delta" should be a "small" negative number, such as (-10) to (-80)
	my:delta[2] = -i
end procedure

integer cfunc1
function Func1Exp(sequence n1, integer exp1, integer targetLength, integer radix)
	integer arrayId, ret
	sequence n2
	arrayId = numArray:new_object_from_data(n1)
	ret = c_func(cfunc1, {arrayId, exp1, targetLength, radix})
	DeleteNumArray(arrayId)
	n2 = GetEun(ret)
	DeleteEun(ret)
	return n2
end function
integer rid = routine_id("Func1Exp")

public function FindRootExp(integer pointer_callback_func1, integer array_n1, integer exp1, 
		integer array_n2, integer exp2, integer len, integer radix)
	-- callback routine must accept four (4) arguments: func1(integer array_n1, integer exp1, integer targetLength, integer radix)
	-- and return an integer, the returned EunId.
	atom maFunc1
	sequence s
	maFunc1 = pointers:get_data_from_object(pointer_callback_func1)
ifdef BITS64 then
	cfunc1 = define_c_func("", maFunc1, {C_LONGLONG, C_LONGLONG, C_LONGLONG, C_LONGLONG}, C_LONGLONG)
elsedef
	cfunc1 = define_c_func("", maFunc1, {C_INT, C_INT, C_INT, C_INT}, C_INT)
end ifdef
	s = my:FindRootExp(rid, numArray:get_data_from_object(array_n1), exp1, numArray:get_data_from_object(array_n2), exp2, len, radix)
	return NewFromEun(s)
end function

-- Complex functions:

public function ComplexCompare(integer c1, integer c2)
	-- Compares real parts, then imaginary parts of two (2) complex numbers
	return my:ComplexCompare(GetComplex(c1), GetComplex(c2)) + 1
end function

public function ComplexAdjustRound(integer c1, integer adjustBy)
	return NewFromComplex(my:ComplexAdjustRound(GetComplex(c1), adjustBy))
end function

public function NegateImaginary(integer complex_a)
	-- Negate the imaginary part of a Complex number
	return NewFromComplex(my:NegateImag(GetComplex(complex_a)))
end function

public function ComplexAdd(integer complex_a, integer complex_b)
	return NewFromComplex(my:ComplexAdd(GetComplex(complex_a), GetComplex(complex_b)))
end function

public function ComplexNegate(integer complex_a)
	return NewFromComplex(my:ComplexNegate(GetComplex(complex_a)))
end function

public function ComplexSubtract(integer complex_a, integer complex_b)
	return NewFromComplex(my:ComplexSubtract(GetComplex(complex_a), GetComplex(complex_b)))
end function

public function ComplexMultiply(integer complex_a, integer complex_b)
	-- n1 = (a+bi)
	-- n2 = (c+di)
	-- (a+bi)(c+di) <=> ac + adi + bci + bdii
	-- <=> (ac - bd) + (ad + bc)i
	return NewFromComplex(my:ComplexMultiply(GetComplex(complex_a), GetComplex(complex_b)))
end function

public function ComplexMultiplicativeInverse(integer complex_a)
	-- Eun a, b, c
	-- (a+bi)(a-bi) <=> a*a + b*b
	-- n2 = (a+bi)
	-- a = n2[1]
	-- b = n2[2]
	-- c = (a*a + b*b)
	-- 1 / n2 <=> (a-bi) / (a*a + b*b)
	-- <=> (a / (a*a + b*b)) - (b / (a*a + b*b))i
	-- <=> (a / c) - (b / c)i
	return NewFromComplex(my:ComplexMultiplicativeInverse(GetComplex(complex_a)))
end function

public function ComplexDivide(integer complex_a, integer complex_b)
	return NewFromComplex(my:ComplexDivide(GetComplex(complex_a), GetComplex(complex_b)))
end function

public procedure ComplexSqrt(integer complex_dst1, integer complex_dst2, integer complex_a)
	sequence ret
	ret = my:ComplexSqrt(GetComplex(complex_a))
	if length(ret) = 0 then
		abort(1/0) -- Error: something went wrong
	end if
	complex:replace_object(complex_dst1, ret[1])
	complex:replace_object(complex_dst2, ret[2])
end procedure

public procedure ComplexQuadraticEquation(integer complex_dst1, integer complex_dst2, integer complex_a, integer complex_b, integer complex_c)
	sequence ret
	ret = my:ComplexQuadraticEquation(GetComplex(complex_a), GetComplex(complex_b), GetComplex(complex_c))
	complex:replace_object(complex_dst1, ret[1])
	complex:replace_object(complex_dst2, ret[2])
end procedure

public function EunQuadraticEquation(integer eun_dst1, integer eun_dst2, integer complex_dst1, integer complex_dst2, integer eun_a, integer eun_b, integer eun_c)
	object ret
	ret = my:EunQuadraticEquation(GetEun(eun_a), GetEun(eun_b), GetEun(eun_c))
	if atom(ret) then
		abort(1/0) -- Error: something went wrong
	end if
	if my:Eun(ret[1]) then
		eun:replace_object(eun_dst1, ret[1])
		eun:replace_object(eun_dst2, ret[2])
		return 1 -- for eun's being stored
	else
		complex:replace_object(complex_dst1, ret[1])
		complex:replace_object(complex_dst2, ret[2])
		return 2 -- for complex's being stored
	end if
end function

-- Added functions:

-- Statistics

integer eun_sort_id = routine_id("EunCompare")
integer complex_sort_id = routine_id("ComplexCompare")

function custom_sort(integer custom_compare, sequence x, object data = {}, integer order = 1)
	integer gap, j, first, last
	object tempi, tempj, result
	sequence args = {0, 0}

	if order >= 0 then
		order = -1
	else
		order = 1
	end if

	if atom(data) then
		args &= data
	elsif length(data) then
		args = append(args, data[1])
	end if

	last = length(x)
	gap = floor(last / 10) + 1
	while 1 do
		first = gap + 1
		for i = first to last do
			tempi = x[i]
			args[1] = tempi
			j = i - gap
			while 1 do
				tempj = x[j]
				args[2] = tempj
				result = call_func(custom_compare, args)
				if sequence(result) then
					args[3] = result[2]
					result = result[1]
				end if
				if eu:compare(result, 0) != order then
					j += gap
					exit
				end if
				x[j+gap] = tempj
				if j <= gap then
					exit
				end if
				j -= gap
			end while
			x[j] = tempi
		end for
		if gap = 1 then
			return x
		else
			gap = floor(gap / 7) + 1
		end if
	end while
end function

function get4s_from_null_terminating_array(atom ma)
	atom findnull
	integer len
	findnull = ma
	while peek4s(findnull) != 0 do
		findnull += 4
	end while
	len = floor((findnull - ma) / 4)
	return peek4s({ma, len})
end function

public procedure EunSort(integer pointer_to_ids_null_terminating_array, integer order)
	atom ma
	sequence s
	ma = pointers:get_data_from_object(pointer_to_ids_null_terminating_array)
	s = get4s_from_null_terminating_array(ma)
	if order = 0 then
		order = -1
	end if
	s = custom_sort(eun_sort_id, s, {}, order) -- order is either: 1 or (-1).
	poke4(ma, s)
end procedure
public procedure ComplexSort(integer pointer_to_ids_null_terminating_array, integer order)
	atom ma
	sequence s
	ma = pointers:get_data_from_object(pointer_to_ids_null_terminating_array)
	s = get4s_from_null_terminating_array(ma)
	if order = 0 then
		order = -1
	end if
	s = custom_sort(complex_sort_id, s, {}, order) -- order is either: 1 or (-1).
	poke4(ma, s)
end procedure

public function EunSum(integer dstId, integer pointer_to_ids_null_terminating_array)
	atom ma
	sequence data, sum
	ma = pointers:get_data_from_object(pointer_to_ids_null_terminating_array)
	data = get4s_from_null_terminating_array(ma)
	sum = my:NewEun()
	for i = 1 to length(data) do
		sum = my:EunAdd(sum, GetEun(data[i]))
	end for
	eun:replace_object(dstId, sum)
	return length(data)
end function
public function ComplexSum(integer dstId, integer pointer_to_ids_null_terminating_array)
	atom ma
	sequence data, sum
	ma = pointers:get_data_from_object(pointer_to_ids_null_terminating_array)
	data = get4s_from_null_terminating_array(ma)
	sum = my:NewComplex()
	for i = 1 to length(data) do
		sum = my:ComplexAdd(sum, GetComplex(data[i]))
	end for
	complex:replace_object(dstId, sum)
	return length(data)
end function

-- mean, median, mode

-- mean -- average, sum / count

public function EunMean(integer pointer_to_ids_null_terminating_array)
	integer sumId, len
	sequence s
	sumId = eun:getNewId()
	len = EunSum(sumId, pointer_to_ids_null_terminating_array)
	s = GetEun(sumId)
	s = my:EunDivide(s, my:NewEun(my:Carry({len}, s[4]), 0, s[3], s[4]))
	eun:replace_object(sumId, s)
	return sumId -- actually retId.
end function
public function ComplexMean(integer pointer_to_ids_null_terminating_array)
	integer sumId, len
	sequence s
	sumId = complex:getNewId()
	len = ComplexSum(sumId, pointer_to_ids_null_terminating_array)
	s = GetComplex(sumId)
	s = my:ComplexDivide(s, {my:NewEun(my:Carry({len}, s[4]), 0, s[3], s[4]), my:NewEun({}, 0, s[3], s[4])})
	complex:replace_object(sumId, s)
	return sumId -- actually retId.
end function

-- median -- middle value, when sorted, averaged

public function EunMedian(integer pointer_to_ids_null_terminating_array, integer order)
	atom ma
	sequence s, num
	integer pos, resultId
	EunSort(pointer_to_ids_null_terminating_array, order)
	ma = pointers:get_data_from_object(pointer_to_ids_null_terminating_array)
	s = get4s_from_null_terminating_array(ma)
	pos = Ceil(length(s) / 2)
	if IsPositiveEven(length(s)) then
		-- Average the two in the middle:
		num = my:EunAdd(GetEun(s[pos]), GetEun(s[pos + 1]))
		num = my:EunDivide(num, my:NewEun({2}, 0, num[3], num[4]))
		resultId = NewFromEun(num)
	else
		resultId = CloneEun(s[pos])
	end if
	return resultId
end function
public function ComplexMedian(integer pointer_to_ids_null_terminating_array, integer order)
	atom ma
	sequence s, num
	integer pos, resultId
	ComplexSort(pointer_to_ids_null_terminating_array, order)
	ma = pointers:get_data_from_object(pointer_to_ids_null_terminating_array)
	s = get4s_from_null_terminating_array(ma)
	pos = Ceil(length(s) / 2)
	if IsPositiveEven(length(s)) then
		-- Average the two in the middle:
		num = my:ComplexAdd(GetComplex(s[pos]), GetComplex(s[pos + 1]))
		num = my:ComplexDivide(num, {my:NewEun({2}, 0, s[3], s[4]), my:NewEun({}, 0, s[3], s[4])})
		resultId = NewFromComplex(num)
	else
		resultId = CloneComplex(s[pos])
	end if
	return resultId
end function

-- mode -- numbers that show up 2 or more times, the max of them.

function sort(sequence x, integer order = 1)
	integer gap, j, first, last
	object tempi, tempj

	if order >= 0 then
		order = -1
	else
		order = 1
	end if


	last = length(x)
	gap = floor(last / 10) + 1
	while 1 do
		first = gap + 1
		for i = first to last do
			tempi = x[i]
			j = i - gap
			while 1 do
				tempj = x[j]
				if eu:compare(tempi, tempj) != order then
					j += gap
					exit
				end if
				x[j+gap] = tempj
				if j <= gap then
					exit
				end if
				j -= gap
			end while
			x[j] = tempi
		end for
		if gap = 1 then
			return x
		else
			gap = floor(gap / 7) + 1
		end if
	end while
end function


function raw_frequency(object data_set) --, object subseq_opt = ST_ALLNUM)
	
	sequence lCounts
	sequence lKeys
	integer lNew = 0
	integer lPos
	integer lMax = -1
	
	if atom(data_set) then
		return {{1,data_set}}
	end if
	
	-- data_set = massage(data_set, subseq_opt)
	
	if length(data_set) = 0 then
		return {{1,data_set}}
	end if
	lCounts = repeat({0,0}, length(data_set))
	lKeys   = repeat(0, length(data_set))
	for i = 1 to length(data_set) do
		lPos = find(data_set[i], lKeys)
		if lPos = 0 then
			lNew += 1
			lPos = lNew
			lCounts[lPos][2] = data_set[i]
			lKeys[lPos] = data_set[i]
			if lPos > lMax then
				lMax = lPos
			end if
		end if
		lCounts[lPos][1] += 1
	end for
	return sort(lCounts[1..lMax], -1)
	
end function

function mode(sequence data_set) --, object subseq_opt = ST_ALLNUM)
	
	sequence lCounts
	sequence lRes
	
	-- data_set = massage(data_set, subseq_opt)
	
	if not length( data_set ) then
		return {}
	end if

	lCounts = raw_frequency(data_set) --, subseq_opt)
	
	lRes = {lCounts[1][2]}
	for i = 2 to length(lCounts) do
		if lCounts[i][1] < lCounts[1][1] then
			exit
		end if
		lRes = append(lRes, lCounts[i][2])
	end for
	
	return lRes
	
end function


public function EunMode(integer pointer_to_ids_null_terminating_array)
	atom ma
	sequence s
	ma = pointers:get_data_from_object(pointer_to_ids_null_terminating_array)
	s = get4s_from_null_terminating_array(ma)
	for i = 1 to length(s) do
		s[i] = GetEun(s[i])
	end for
	s = mode(s)
	for i = 1 to length(s) do
		s[i] = NewFromEun(s[i])
	end for
	s = s & {0}
ifdef BITS64 then
	ma = allocate_data(length(s) * 8)
elsedef
	ma = allocate_data(length(s) * 4)
end ifdef
	poke4(ma, s)
	return pointers:new_object_from_data(ma)
end function
public function ComplexMode(integer pointer_to_ids_null_terminating_array)
	atom ma
	sequence s
	ma = pointers:get_data_from_object(pointer_to_ids_null_terminating_array)
	s = get4s_from_null_terminating_array(ma)
	for i = 1 to length(s) do
		s[i] = GetComplex(s[i])
	end for
	s = mode(s)
	for i = 1 to length(s) do
		s[i] = NewFromComplex(s[i])
	end for
	s = s & {0}
ifdef BITS64 then
	ma = allocate_data(length(s) * 8)
elsedef
	ma = allocate_data(length(s) * 4)
end ifdef
	poke4(ma, s)
	return pointers:new_object_from_data(ma)
end function

-- "Accurate" function:

public function GetMoreAccuratePrec(integer eun_n1, integer prec)
	return my:GetMoreAccuratePrec(GetEun(eun_n1), prec)
end function

-- dropped support for the other "accurate" functions
-- use the larger of the two, and then the smaller of the two's precision or targetLength

public procedure SetForSmallRadix(integer i)
	my:SetForSmallRadix(i)
end procedure

public function GetForSmallRadix()
	return my:GetForSmallRadix()
end function

public procedure SetIsRoundToZero(integer i)
	my:SetIsRoundToZero(i)
end procedure
public function GetIsRoundToZero()
	return my:GetIsRoundToZero()
end function

public function EunGetPrec(integer eun_n1)
	return my:EunGetPrec(GetEun(eun_n1))
end function

public function EunTest(integer eun_n1, integer eun_n2)
	sequence range
	range = my:EunTest(GetEun(eun_n1), GetEun(eun_n2))
	return range[1]
end function

public function MultiplicativeInverseGuessExp(integer den1, integer exp1, integer targetLength, integer radix, integer guess_id)
	return NewFromEun(my:MultiplicativeInverseExp(numArray:get_data_from_object(den1), exp1, targetLength, radix, numArray:get_data_from_object(guess_id)))
end function

public function EunMultiplicativeInverseGuess(integer n1, integer array_guess_id)
	return NewFromEun(my:EunMultiplicativeInverse(GetEun(n1), numArray:get_data_from_object(array_guess_id)))
end function

public procedure SetDivideByZeroFlag(integer i)
	my:SetDivideByZeroFlag(i)
end procedure

-- public Bool zeroDividedByZeroFlag = TRUE -- if true, zero divided by zero returns one (0/0 = 1)

public function GetZeroDividedByZeroFlag()
	return my:GetZeroDividedByZeroFlag()
end function
public procedure SetZeroDividedByZeroFlag(integer i)
	my:SetZeroDividedByZeroFlag(i)
end procedure

public function IsProperLengthAndRadix(integer targetLength, integer radix)
	return my:IsProperLengthAndRadix(targetLength, radix)
end function

public function NewEunWithPointer(integer arrayid, integer signedExponentPointerId, integer radix, integer targetLength)
ifdef BITS64 then
	return NewFromEun(my:NewEun(numArray:get_data_from_object(arrayid), peek8s(pointers:get_data_from_object(signedExponentPointerId)), radix, targetLength))
elsedef
	return NewFromEun(my:NewEun(numArray:get_data_from_object(arrayid), peek4s(pointers:get_data_from_object(signedExponentPointerId)), radix, targetLength))
end ifdef
end function

public procedure SetEurootsAdjustRound(PositiveInteger i)
	my:SetEurootsAdjustRound(i)
end procedure

public function GetEurootsAdjustRound()
	return my:GetEurootsAdjustRound()
end function

public procedure SetComplexSqrtAdjustRound(PositiveInteger i)
	my:SetComplexSqrtAdjustRound(i)
end procedure

public function GetComplexSqrtAdjustRound()
	return my:GetComplexSqrtAdjustRound()
end function


public function EunPower(integer base, integer raisedTo)
	return NewFromEun(my:EunPower(GetEun(base), GetEun(raisedTo)))
end function


public function NewComplexMatrix(integer rows, integer cols, integer pointer_to_complex_ids_null_terminating_array)
	integer pos
	atom ma
	sequence s, ret
	ma = pointers:get_data_from_object(pointer_to_complex_ids_null_terminating_array)
	s = get4s_from_null_terminating_array(ma)
	ret = my:NewComplexMatrix(rows, cols)
	pos = 1
	for row = 1 to rows do
		for col = 1 to cols do
			ret[row][col] = GetComplex(s[pos])
			pos += 1
		end for
	end for
	return matrix:new_object_from_data(ret)
end function

public procedure DeleteComplexMatrix(integer i)
	matrix:delete_object(i)
end procedure

public procedure StoreComplexMatrix(integer id_dst, integer id_src)
	matrix:store_object(id_dst, id_src)
end procedure

public function CloneComplexMatrix(integer id)
	return matrix:clone_object(id)
end function

public function ComplexMatrixToArray(integer id)
	matrix a = matrix:get_data_from_object(id)
	integer rows, cols, len, row, size
	atom ma
	rows = my:GetMatrixRows(a)
	cols = my:GetMatrixCols(a)
	len = rows * cols
	size = 4 * (len + 1)
	ma = allocate_data(size)
	mem_set(ma, 0, size)
	row = 1
	for offset = 0 to len - 1 by cols do
		poke4(ma + offset * 4, a[row])
		row += 1
	end for
	return pointers:new_object_from_data(ma)
end function


public function GetMatrixRows(integer i)
	return my:GetMatrixRows(matrix:get_data_from_object(i))
end function

public function GetMatrixCols(integer i)
	return my:GetMatrixCols(matrix:get_data_from_object(i))
end function

public function ComplexMatrixMultiply(integer a, integer b)
	return matrix:new_object_from_data(my:ComplexMatrixMultiply(matrix:get_data_from_object(a), matrix:get_data_from_object(b)))
end function

-- end of file.
