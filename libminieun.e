-- Copyright (c) 2016-2021 James Cook
-- LibMiniEun.e

-- Compiles into a dll

-- Can be used by either 32-bit or 64-bit "euc" to make it into a DLL:

-- Example for Watcom 32-bit:
-- C:\> euc -o libmyeun.dll -strict -dll -wat -keep libeun.e
-- Example for GCC:
-- C:\> euc -o libmyeun.dll -strict -dll -gcc -keep libeun.e

-- NOTE: Don't mix ids of different types.

include allocate.e
include dll.e
include classfile.e as pointers
include classfile.e as numArray
include classfile.e as eun
include myeunumber.e as my

public function MiniVersion()
	return 58 -- Need to debug with Wrapper "Stub" (myeun.h)
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
	if pointer = 0 then
		return 0
	end if
	poke8(pointer, 0)
elsedef
	atom pointer = allocate_data(4)
	if pointer = 0 then
		return 0
	end if
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
	if ma = 0 then
		return 0
	end if
	poke8(ma, num)
	poke8(pointers:get_data_from_object(pointer_dstId), ma)
elsedef
	atom ma = allocate_data(length(num) * 4) -- 32bit integers are 4 bytes in size
	if ma = 0 then
		return 0
	end if
	poke4(ma, num)
	poke4(pointers:get_data_from_object(pointer_dstId), ma)
end ifdef
	return length(num)
end function

public procedure FreeNewCIntArrayFromNumArray(integer pointer_dstId)
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

function GetEun(integer id)
	return eun:get_data_from_object(id)
end function

public function isEun(integer n1)
	return my:Eun(GetEun(n1))
end function

function NewFromEun(object n1)
	if my:Eun(n1) then
		return eun:new_object_from_data(n1)
	else
		return 0
	end if
end function

public function NewEun(integer arrayid, integer exp, integer targetLength, integer radix, Bool sign_of_exp)
	if sign_of_exp then
		exp = -(exp)
	end if
	return NewFromEun(my:NewEun(numArray:get_data_from_object(arrayid), exp, targetLength, radix))
end function

public function NewEunWithPointer(integer arrayid, integer signedExponentPointerId, integer targetLength, integer radix)
	ifdef BITS64 then
		return NewFromEun(my:NewEun(numArray:get_data_from_object(arrayid), peek8s(pointers:get_data_from_object(signedExponentPointerId)), targetLength, radix))
	elsedef
		return NewFromEun(my:NewEun(numArray:get_data_from_object(arrayid), peek4s(pointers:get_data_from_object(signedExponentPointerId)), targetLength, radix))
	end ifdef
end function

public procedure DeleteEun(integer id)
	eun:delete_object(id)
end procedure

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
	if ma = 0 then
		return 0
	end if
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
		sleep(nanosleep)
	end while

	return haystack
end function


public function EunPrintToCString(integer x)
	sequence st = pretty_sprint(GetEun(x), {0, 8}) -- 8 spaces for indent
	atom ma
	st = match_replace("\n", st, "\r\n")
	ma = allocate_string(st)
	if ma = 0 then
		return 0
	end if
	return pointers:new_object_from_data(ma)
	-- be sure to call "FreePointer()" after you are done with it
end function

-- Complex's:


-- MyEuNumber functions:

-- list functions to export.

function new_doubleAtom(atom dbl)
	atom pointer
	sequence s
	pointer = allocate_data(8)
	if pointer = 0 then
		return 0
	end if
	s = atom_to_float64(dbl)
	poke(pointer, s)
	return pointers:new_object_from_data(pointer)
	-- use FreePointer() to free this data.
end function

function get_doubleAtom(integer pointer_to_double)
	return float64_to_atom(peek({pointers:get_data_from_object(pointer_to_double), 8}))
end function

public function GetNanoSleep()
-- returns a float64, or a C/C++ "double"
-- nanosleep is a fraction of a second (useful on Linux to make it run cooler); or -1 to disable sleep (this will make it run hot on Linux)
	atom dbl
	dbl = my:GetNanoSleep()
	return new_doubleAtom(dbl)
end function

public procedure SetNanoSleep(integer pointer_to_double) -- takes the registered pointer to a double, it should be a fraction of a second.
	atom d
	d = get_doubleAtom(pointer_to_double)
	my:SetNanoSleep(d)
end procedure

public function GetVersion()
	return my:GetVersion()
end function

public function GetDivideByZeroFlag()
	return my:GetDivideByZeroFlag()
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

public procedure SetIsRoundToZero(integer i)
	my:SetIsRoundToZero(i)
end procedure

public function GetIsRoundToZero()
	return my:GetIsRoundToZero()
end function

-- More Accuracy variables:

public procedure SetMultiplicativeInverseMoreAccuracy(integer i)
	my:SetMultiplicativeInverseMoreAccuracy(i - 1)
end procedure

public function GetMultiplicativeInverseMoreAccuracy()
	return my:GetMultiplicativeInverseMoreAccuracy() + 1
end function

-- End of More Accuracy Variables.

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
	atom speed
	speed = get_doubleAtom(ptrToDblId)
	my:SetCalcSpeed(speed)
end procedure

public function GetCalcSpeed()
	atom dbl
	dbl = my:GetCalcSpeed()
	return new_doubleAtom(dbl)
end function

public procedure SetRoundToNearestOption(integer boolean_value_num)
	my:SetRoundToNearestOption(boolean_value_num)
end procedure

public function GetRoundToNearestOption()
	return my:GetRoundToNearestOption()
end function

public procedure IntegerModeOn()
	my:IntegerModeOn()
end procedure

public procedure IntegerModeOff()
	my:IntegerModeOff()
end procedure

public function GetRoundInf() -- = 1 -- Round towards +infinity or -infinity, (positive or negative infinity)
	return my:ROUND_INF
end function

public function GetRoundZero() -- = 2 -- Round towards zero
	return my:ROUND_ZERO
end function

public function GetRoundTruncate() -- = 3 -- Don't round, truncate
	return my:ROUND_TRUNCATE
end function

public function GetRoundPosInf() -- = 4 -- Round towards positive +infinity
	return my:ROUND_POS_INF
end function

public function GetRoundNegInf() -- = 5 -- Round towards negative -infinity
	return my:ROUND_NEG_INF
end function

public function GetRoundEven() -- = 6 -- Round making number even on halfRadix
	return my:ROUND_EVEN
end function

public function GetRoundOdd() -- = 7 -- Round making number odd on halfRadix
	return my:ROUND_ODD
end function

public procedure SetRound(integer i)
	my:SetRound(i)
end procedure

public function GetRound()
	return my:GetRound()
end function

public function GetMultInvIter()
	return my:iter
end function
public procedure SetMultInvIter(integer i)
	my:iter = i
end procedure
public function GetMultInvLastIterCount()
	return my:lastIterCount
end function
public procedure SetMultInvLastIterCount(integer i)
	my:lastIterCount = i
end procedure

-- MyEuNumber Functions:

public function Min(integer a, integer b)
	if a < b then
		return a
	else
		return b
	end if
end function

public function Max(integer a, integer b)
	if a > b then
		return a
	else
		return b
	end if
end function

public function RoundTowardsZero(integer dblId)
	atom dbl
	dbl = get_doubleAtom(dblId)
	dbl = my:RoundTowardsZero(dbl)
	return new_doubleAtom(dbl)
end function

public function Round(integer dblId1, integer dblId2)
	atom result
	result = my:Round(get_doubleAtom(dblId1), get_doubleAtom(dblId2))
	return new_doubleAtom(result)
end function

public function RangeEqual(integer a, integer b, integer start, integer stop)
	return my:RangeEqual(numArray:get_data_from_object(a), numArray:get_data_from_object(b), start, stop)
end function

public function Equaln(integer a, integer b)
	sequence s
	s = Equaln(numArray:get_data_from_object(a), numArray:get_data_from_object(b))
	return s[1]
end function

public function IsIntegerOdd(integer i)
	return my:IsIntegerOdd(i)
end function

public function IsIntegerEven(integer i)
	return my:IsIntegerEven(i)
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

public function Subtr(integer n1, integer n2)
	return numArray:new_object_from_data(my:Subtr(numArray:get_data_from_object(n1), numArray:get_data_from_object(n2)))
end function

public function ConvertRadix(integer num, integer fromRadix, integer toRadix)
	return numArray:new_object_from_data(my:ConvertRadix(numArray:get_data_from_object(num), fromRadix, toRadix))
end function

public function Multiply(integer n1, integer n2, integer sumOfLengths, integer flag)
	object ob1, ob2, val -- val for "value"
	ob1 = numArray:get_data_from_object(n1)
	ob2 = numArray:get_data_from_object(n2)
	if flag then
		val = my:Multiply(ob1, ob2)
	else
		val = my:Multiply(ob1, ob2, sumOfLengths - 1)
	end if
	return numArray:new_object_from_data(val)
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

public function Subtract(integer num, integer radix, integer isMixed)
	return numArray:new_object_from_data(my:Subtract(numArray:get_data_from_object(num), radix, isMixed))
end function

public function TrimLeadingZeros(integer num)
	return numArray:new_object_from_data(my:TrimLeadingZeros(numArray:get_data_from_object(num)))
end function

public function TrimTrailingZeros(integer num)
	return numArray:new_object_from_data(my:TrimTrailingZeros(numArray:get_data_from_object(num)))
end function

public function AdjustRound(integer num, integer exponent, integer targetLength, integer radix, integer optionsIsMixed, Bool isNegExp)
	-- default optionsIsMixed is 1, can be: (0, 1, 2)
	if isNegExp then
		exponent = - (exponent)
	end if
	return NewFromEun(my:AdjustRound(numArray:get_data_from_object(num), exponent, targetLength, radix, optionsIsMixed))
end function

--here, make Exp functions have flags for "exp1 and exp2"'s sign.


public function MultiplyExp(integer n1, integer exp1, integer n2, integer exp2, integer targetLength, integer radix, Bool isNegExp1, Bool isNegExp2)
	if isNegExp1 then
		exp1 = - (exp1)
	end if
	if isNegExp2 then
		exp2 = - (exp2)
	end if
	return NewFromEun(my:MultiplyExp(numArray:get_data_from_object(n1), exp1, numArray:get_data_from_object(n2), exp2, targetLength, radix))
end function

public function SquareExp(integer n1, integer exp1, integer targetLength, integer radix, Bool isNegExp1)
	if isNegExp1 then
		exp1 = - (exp1)
	end if
	return NewFromEun(my:SquareExp(numArray:get_data_from_object(n1), exp1, targetLength, radix))
end function

public function AddExp(integer n1, integer exp1, integer n2, integer exp2, integer targetLength, integer radix, Bool isNegExp1, Bool isNegExp2)
	if isNegExp1 then
		exp1 = - (exp1)
	end if
	if isNegExp2 then
		exp2 = - (exp2)
	end if
	return NewFromEun(my:AddExp(numArray:get_data_from_object(n1), exp1, numArray:get_data_from_object(n2), exp2, targetLength, radix))
end function

public function SubtractExp(integer n1, integer exp1, integer n2, integer exp2, integer targetLength, integer radix, Bool isNegExp1, Bool isNegExp2)
	if isNegExp1 then
		exp1 = - (exp1)
	end if
	if isNegExp2 then
		exp2 = - (exp2)
	end if
	return NewFromEun(my:SubtractExp(numArray:get_data_from_object(n1), exp1, numArray:get_data_from_object(n2), exp2, targetLength, radix))
end function

procedure dummy(integer i)
	-- procedure with no code in its body.
end procedure

my:divideCallBackId = routine_id("dummy")

public function MultiplicativeInverseExp(integer den1, integer exp1, integer targetLength, integer radix, integer guess, Bool isNegExp1)
	sequence s = {}
	-- guess is 0, when you want it to guess the result instead of you supplying the guess.
	if guess > 0 then
		s = numArray:get_data_from_object(guess)
	end if
	if isNegExp1 then
		exp1 = - (exp1)
	end if
	s = my:MultiplicativeInverseExp(numArray:get_data_from_object(den1), exp1, targetLength, radix, s)
	return NewFromEun(s)
end function

public function DivideExp(integer num1, integer exp1, integer den2, integer exp2, integer targetLength, integer radix, Bool isNegExp1, Bool isNegExp2)
	sequence s
	if isNegExp1 then
		exp1 = - (exp1)
	end if
	if isNegExp2 then
		exp2 = - (exp2)
	end if
	s = my:DivideExp(numArray:get_data_from_object(num1), exp1, numArray:get_data_from_object(den2), exp2, targetLength, radix)
	return NewFromEun(s)
end function

public function ConvertExp(integer n1, integer exp1, integer targetLength, integer fromRadix, integer toRadix, Bool isNegExp1)
	sequence s
	if isNegExp1 then
		exp1 = - (exp1)
	end if
	s = my:ConvertExp(numArray:get_data_from_object(n1), exp1, targetLength, fromRadix, toRadix)
	return NewFromEun(s)
end function

public function IsProperLengthAndRadix(integer targetLength, integer radix)
	return my:IsProperLengthAndRadix(targetLength, radix)
end function


-- Begin Eun:

public function EunAdjustRound(integer n1, integer adjustBy) -- if adjustBy = 0 then use default adjustRound
	return NewFromEun(my:EunAdjustRound(GetEun(n1), adjustBy))
end function

public procedure RemoveLastDigits(integer n1, integer digits)
	eun:privateData[n1][1] = eun:privateData[n1][1][1..$-digits]
end procedure

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

public function EunMultiplicativeInverseGuess(integer n1, integer array_guess_id)
	return NewFromEun(my:EunMultiplicativeInverse(GetEun(n1), numArray:get_data_from_object(array_guess_id)))
end function

public function EunDivide(integer n1, integer n2)
	return NewFromEun(my:EunDivide(GetEun(n1), GetEun(n2)))
end function

public function EunConvert(integer n1, integer toRadix, integer targetLength)
	return NewFromEun(my:EunConvert(GetEun(n1), toRadix, targetLength))
end function

public function CompareExp(sequence n1, integer exp1, sequence n2, integer exp2, Bool isNegExp1, Bool isNegExp2)
	if isNegExp1 then
		exp1 = - (exp1)
	end if
	if isNegExp2 then
		exp2 = - (exp2)
	end if
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

public function EunCombInt(integer n1, integer adjustBy, integer up) -- values for "up" can be: 0, 1, 2
	return NewFromEun(my:EunCombInt(GetEun(n1), adjustBy, up - 1))
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
ifdef WINDOWS then
	atom ma = my:ToMemory(GetEun(n1), 1)
elsedef
	atom ma = my:ToMemory(GetEun(n1))
end ifdef
	return pointers:new_object_from_data(ma)
end function

public function FromMemoryToEun(integer pointer_id)
	sequence n1 = my:FromMemoryToEun(pointers:get_data_from_object(pointer_id))
	return NewFromEun(n1)
end function

-- NthRoot functions:

-- mymath.e functions:

-- PI and E constants:

-- Logarithms:

-- Powers: a number (base), raised to the power of another number (raisedTo)

-- Begin Trig Functions:

-- Triangulation using two (2) points

-- myeuroots.e:

-- Complex functions:

-- Added functions:

-- (Could keep these in Mini, but decided not to.)
