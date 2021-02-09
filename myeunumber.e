-- Copyright (c) 2020 James Cook
-- Eunumber, advanced sequence based arithmetic with exponents

--FILES: (All as one file.)
--namespace my
--public include myeunumber.e
--public include numio.e
--public include nthroot.e
--public include mymath.e
--public include triangulation.e
--public include myeuroots.e
--public include mycomplex.e
--public include quadraticequation.e
--additions at end of file.

namespace myeunumber

ifdef BITS64 then
	include std/machine.e
	include std/convert.e
elsedef
	include allocate.e
end ifdef

include misc.e
include get.e

-- with trace

-- NOTE: Negated integer named variables should be in parenthesis.

public function GetVersion() -- revision number
	return 161 -- completely type checked version
end function

-- MyEunumber

-- Big endian. Sequence math. With exponents.

-- #Big endian functions:

-- GetDivideByZeroFlag()
-- SetDefaultTargetLength(integer i)
-- GetDefaultTargetLength()
-- SetDefaultRadix(integer i)
-- GetDefaultRadix()
-- SetAdjustRound(integer i)
-- GetAdjustRound()
-- SetCalcSpeed(atom speed)
-- GetCalcSpeed()
-- SetMoreAccuracy(integer i)
-- GetMoreAccuracy()
-- SetRound(integer i)
-- GetRound()
-- SetRoundToNearestOption(integer boolean_value_num)
-- GetRoundToNearestOption()

-- RoundTowardsZero
-- Equaln
-- IsIntegerOdd(integer i)
-- IsIntegerEven(integer i)

-- Borrow
-- Carry
-- CarryRadixOnly
-- Add
-- Sum
-- ConvertRadix
-- Multiply
-- Square
-- IsNegative
-- Negate
-- AbsoluteValue
-- Subtract
-- TrimLeadingZeros
-- TrimTrailingZeros
-- CarryRadixOnlyEx
-- AdjustRound
-- MultiplyExp
-- AddExp

-- ProtoMultiplicativeInverseExp
-- IntToDigits
-- ExpToAtom
-- GetGuessExp
-- MultiplicativeInverseExp
-- DivideExp
-- ConvertExp

-- Eun (type)
-- NewEun
-- EunAdjustRound(Eun n1, integer adjustBy = -1)
-- EunMultiply
-- EunSquare
-- EunAdd
-- EunNegate
-- EunAbsoluteValue
-- EunSubtract
-- EunMultiplicativeInverse
-- EunDivide
-- EunConvert

-- CompareExp
-- GetEqualLength
-- EunCompare
-- EunReverse -- reverse endian
-- EunFracPart -- returns the fraction part (no Rounding)
-- EunIntPart -- returns the integer part (no Rounding)
-- EunRoundSig -- Round to number of significant digits
-- EunRoundSignificantDigits -- same as EunRoundSig
-- EunRoundToInt -- Round to nearest integer
-- EunCombInt(Eun n1, integer adjustBy = -1)
-- EunModf(Eun fp) -- similar to C's "modf()"
-- EunfDiv(Eun num, Eun den) -- similar to C's "div()"
-- EunfMod(Eun num, Eun den) -- similar to C's "fmod()", just the "mod" or remainder

ifdef BITS64 then
public constant DOUBLE_MAX = 18446744073709551615 -- (power(2, 64) - 1)
public constant DOUBLE_MIN = -DOUBLE_MAX
public constant DOUBLE_RADIX = floor(sqrt(DOUBLE_MAX)) + 1 -- 4294967296
public constant DOUBLE_RADIX10 = 1000000000
public constant INT_MAX = power(2, 62) - 1 -- value: 4611686018427387903
public constant MAX_RADIX = power(2, floor(62/2)-4) -- value: 134217728
public constant INT_MAX10 = power(10, 18) -- value: 1000000000000000000
public constant MAX_RADIX10 = power(10, 8-1) -- value: 100000000
elsedef
public constant DOUBLE_MAX = 9007199254740991 -- (power(2, 53) - 1)
public constant DOUBLE_MIN = -DOUBLE_MAX
public constant DOUBLE_RADIX = floor(sqrt(DOUBLE_MAX)) + 1 -- 94906266
public constant DOUBLE_RADIX10 = 10000000
public constant INT_MAX = power(2, 30) - 1 -- value: 1073741823
public constant MAX_RADIX = power(2, floor(30/2)-4) -- value: 2048
public constant INT_MAX10 = power(10, 9) -- value: 1000000000
public constant MAX_RADIX10 = power(10, 4-1) -- value: 1000
end ifdef

public function abs(atom a)
	if a >= 0 then
		return a
	else
		return -a
	end if
end function

public function Ceil(atom a)
	return -floor(-a)
end function

public type PositiveInteger(integer i)
	return i >= 0
end type

public type NegativeInteger(integer i)
	return i < 0
end type

public type PositiveScalar(integer i)
	return i >= 2
end type

public type NegativeScalar(integer i)
	return i <= -2
end type

public type PositiveOption(integer i)
	return i >= -1
end type

public type PositiveAtom(atom a)
	return a >= 0.0
end type

public type NegativeAtom(atom a)
	return a < 0.0
end type

public type AtomRadix(atom a)
	return a >= 1.001 and a <= DOUBLE_RADIX -- must be larger than 1.0
end type

public function iff(integer condition, object iftrue, object iffalse)
	if condition then
		return iftrue
	else
		return iffalse
	end if
end function

public constant TRUE = 1, FALSE = 0

public type Bool(integer i)
	return i = FALSE or i = TRUE
end type

ifdef USE_TASK_YIELD then
public Bool useTaskYield = FALSE -- TRUE
end ifdef

public Bool divideByZeroFlag = FALSE

public function GetDivideByZeroFlag()
	return divideByZeroFlag
end function
public procedure SetDivideByZeroFlag(Bool i)
	divideByZeroFlag = i
end procedure

public Bool zeroDividedByZeroFlag = TRUE -- if true, zero divided by zero returns one (0/0 = 1)

public function GetZeroDividedByZeroFlag()
	return zeroDividedByZeroFlag
end function
public procedure SetZeroDividedByZeroFlag(Bool i)
	zeroDividedByZeroFlag = i
end procedure

public PositiveScalar defaultTargetLength = 60 -- 40 -- 70 -- 70 * 3 = 210 (I tried to keep it under 212)
public AtomRadix defaultRadix = 10 -- 10 is good for everything from 16-bit shorts, to 32-bit ints, to 64-bit long longs.
public Bool isRoundToZero = FALSE -- make TRUE to allow rounding small numbers to zero.
public PositiveInteger adjustRound = 5 -- 3 -- can be 0 to a small integer, removes digits of inaccuracy, or adds digits of accuracy under ROUND_TO_NEAREST_OPTION
public PositiveAtom calculationSpeed = floor(defaultTargetLength / 2) -- can be 0 or from 1 to targetLength
public PositiveOption multInvMoreAccuracy = -1 -- 15, if -1, then use calculationSpeed

public procedure SetIsRoundToZero(Bool i)
	isRoundToZero = i
end procedure
public function GetIsRoundToZero()
	return isRoundToZero
end function

public procedure SetMultiplicativeInverseMoreAccuracy(PositiveOption i)
	multInvMoreAccuracy = i
end procedure
public function GetMultiplicativeInverseMoreAccuracy()
	return multInvMoreAccuracy
end function

public procedure SetDefaultTargetLength(PositiveScalar i)
	defaultTargetLength = i
end procedure
public function GetDefaultTargetLength()
	return defaultTargetLength
end function

public procedure SetDefaultRadix(AtomRadix i)
	defaultRadix = i
end procedure
public function GetDefaultRadix()
	return defaultRadix
end function

public procedure SetAdjustRound(PositiveInteger i)
	adjustRound = i
end procedure
public function GetAdjustRound()
	return adjustRound
end function

public procedure SetCalcSpeed(PositiveAtom speed)
	calculationSpeed = speed
end procedure
public function GetCalcSpeed()
	return calculationSpeed
end function

public integer iter = 1000000000 -- max number of iterations before returning
public integer lastIterCount = -1 -- MultiplicativeInverseExp has not been called yet, so the value is -1

public constant ATOM_EPSILON = 2.22044604925031308085e-16 -- DBL_EPSILON 64-bit
public constant ATOM_MAX = 1.0e+308 -- 1.79769313486231570815e+308 -- DBL_MAX 64-bit
public constant ATOM_MIN = 1.0e-308 -- 2.22507385850720138309e-308 -- DBL_MIN 64-bit
public constant LOG_ATOM_MAX = log(1.0e+308) -- LOG_DBL_MAX is: 7.09782712893383973096e+02, 64-bit
public constant LOG_ATOM_MIN = log(1.0e-308) -- LOG_DBL_MIN is: -7.08396418532264078749e+02, 64-bit

public constant ROUND_INF = 1 -- Round towards +infinity or -infinity, (positive or negative infinity)
public constant ROUND_ZERO = 2 -- Round towards zero
public constant ROUND_TRUNCATE = 3 -- Don't round, truncate
public constant ROUND_POS_INF = 4 -- Round towards positive +infinity
public constant ROUND_NEG_INF = 5 -- Round towards negative -infinity
-- round even:
public constant ROUND_EVEN = 6 -- Round making number even on halfRadix
-- round odd:
public constant ROUND_ODD = 7 -- Round making number odd on halfRadix
public Bool ROUND_TO_NEAREST_OPTION = FALSE -- Round to nearest whole number (Eun integer), true or false

public procedure SetRoundToNearestOption(Bool boolean_value_num)
	ROUND_TO_NEAREST_OPTION = boolean_value_num
end procedure
public function GetRoundToNearestOption()
	return ROUND_TO_NEAREST_OPTION
end function

public procedure IntegerModeOn()
	ROUND_TO_NEAREST_OPTION = 1
end procedure
public procedure IntegerModeOff()
	ROUND_TO_NEAREST_OPTION = 0
end procedure

type Round2(integer i)
	return i >= 1 and i <= 7
end type

public constant ROUND_AWAY_FROM_ZERO = ROUND_INF
public constant ROUND_TOWARDS_ZERO = ROUND_ZERO
public constant ROUND_TOWARDS_NEGATIVE_INFINITY = ROUND_NEG_INF
public constant ROUND_TOWARDS_POSITIVE_INFINITY = ROUND_POS_INF

public constant ROUND_DOWN = ROUND_NEG_INF -- Round downward.
public constant ROUND_UP = ROUND_POS_INF -- Round upward.

-- public for "doFile.ex":
public Round2 ROUND = ROUND_INF -- or you could try: ROUND_INF or any other ROUND method

public procedure SetRound(Round2 i)
	ROUND = i
end procedure
public function GetRound()
	return ROUND
end function

public function RoundTowardsZero(atom x)
	if x < 0 then
		return Ceil(x)
	else
		return floor(x)
	end if
end function

public function Round(object a, object precision = 1)
	return floor(0.5 + (a * precision )) / precision
end function

public function RangeEqual(sequence a, sequence b, PositiveInteger start, PositiveInteger stop)
	if length(a) >= stop and length(b) >= stop then
		for i = stop to start by -1 do
			if a[i] != b[i] then
				return 0
			end if
		end for
		return 1
	end if
	return 0
end function

public function Equaln(sequence a, sequence b)
	integer minlen, maxlen
ifdef USE_TASK_YIELD then
	if useTaskYield then
		task_yield()
	end if
end ifdef
	if length(a) > length(b) then
		maxlen = length(a)
		minlen = length(b)
	else
		maxlen = length(b)
		minlen = length(a)
	end if
	for i = 1 to minlen do
		if a[i] != b[i] then
			return {i - 1, maxlen}
		end if
	end for
	return {minlen, maxlen}
end function

public function IsIntegerOdd(integer i)
	return remainder(i, 2) and 1
end function

public function IsIntegerEven(integer i)
	return not IsIntegerOdd(i)
end function

-- Function definition
public function Borrow(sequence numArray, AtomRadix radix)
	for i = length(numArray) to 2 by -1 do
		if numArray[i] < 0 then
			numArray[i] += radix
			numArray[i - 1] -= 1
		end if
	end for
	return numArray
end function

public function NegativeBorrow(sequence numArray, AtomRadix radix)
	for i = length(numArray) to 2 by -1 do
		if numArray[i] > 0 then
			numArray[i] -= radix
			numArray[i - 1] += 1
		end if
	end for
	return numArray
end function

public function Carry(sequence numArray, AtomRadix radix)
	atom q, r, b
	integer i
	i = length(numArray)
	while i > 0 do
		b = numArray[i]
		if b >= radix then
			q = floor(b / radix)
			r = remainder(b, radix)
			numArray[i] = r
			if i = 1 then
				numArray = prepend(numArray, q)
			else
				i -= 1
				-- q += numArray[i] -- test for integer overflow
				numArray[i] += q
			end if
		else
			i -= 1
		end if
	end while
	return numArray
end function

public function NegativeCarry(sequence numArray, AtomRadix radix)
	atom q, r, b, negativeRadix
	integer i
	negativeRadix = -radix
	i = length(numArray)
	while i > 0 do
		b = numArray[i]
		if b <= negativeRadix then
			q = -floor(b / negativeRadix) -- bug fix
			r = remainder(b, radix)
			numArray[i] = r
			if i = 1 then
				numArray = prepend(numArray, q)
			else
				i -= 1
				-- q += numArray[i] -- test for integer overflow
				numArray[i] += q
			end if
		else
			i -= 1
		end if
	end while
	return numArray
end function

public function Add(sequence n1, sequence n2)
	integer c, len
	sequence numArray
	if length(n1) >= length(n2) then
		len = length(n2)
		c = length(n1) - (len)
		-- copy n1 to numArray:
		numArray = n1
		for i = 1 to len do
			c += 1
			numArray[c] += n2[i]
		end for
	else
		len = length(n1)
		c = length(n2) - (len)
		-- copy n2 to numArray:
		numArray = n2
		for i = 1 to len do
			c += 1
			numArray[c] += n1[i]
		end for
	end if
	return numArray
end function

public function Subtr(sequence n1, sequence n2)
	integer c, len
	sequence numArray
	if length(n1) >= length(n2) then
		len = length(n2)
		c = length(n1) - (len)
		-- copy n1 to numArray:
		numArray = n1
		for i = 1 to len do
			c += 1
			numArray[c] -= n2[i]
		end for
	else
		len = length(n1)
		c = length(n2) - (len)
		-- copy n2 to numArray:
		numArray = n2
		for i = 1 to len do
			c += 1
			numArray[c] = n1[i] - numArray[c]
		end for
	end if
	return numArray
end function

public function Sum(sequence numArray, sequence args)
	sequence arg
	for i = 1 to length(args) do
		arg = args[i]
		numArray = Add(numArray, arg)
	end for
	return numArray
end function


public function ConvertRadix(sequence number, AtomRadix fromRadix, AtomRadix toRadix)
	sequence target, base, tmp
	atom digit
	target = {} -- same as: {0}
	if length(number) then
		base = {1}
		if number[1] < 0 then
			for i = length(number) to 1 by -1 do
				tmp = base
				digit = number[i]
				for j = 1 to length(tmp) do
					tmp[j] *= digit
				end for
				target = Add(target, tmp)
				target = NegativeCarry(target, toRadix)
				for j = 1 to length(base) do
					base[j] *= fromRadix
				end for
				base = Carry(base, toRadix)
			end for
		else
			for i = length(number) to 1 by -1 do
				tmp = base
				digit = number[i]
				for j = 1 to length(tmp) do
					tmp[j] *= digit
				end for
				target = Add(target, tmp)
				target = Carry(target, toRadix)
				for j = 1 to length(base) do
					base[j] *= fromRadix
				end for
				base = Carry(base, toRadix)
			end for
		end if
	end if
	return target
end function

public function Multiply(sequence n1, sequence n2)
	integer h, len
	atom g
	sequence numArray
	if length(n1) = 0 or length(n2) = 0 then
		return {}
	end if
	len = length(n1) + length(n2) - 1
-- This method may be faster:
	numArray = repeat(0, len)
	for i = 1 to length(n1) do
		h = i
		g = n1[i]
		for j = 1 to length(n2) do
			numArray[h] += g * n2[j]
			h += 1
		end for
	end for
	return numArray
end function

public function Square(sequence n1)
	return Multiply(n1, n1) -- multiply it by its self, once
end function

public function IsNegative(sequence numArray)
	if length(numArray) then
		return numArray[1] < 0
	end if
	return 0
end function

public function Negate(sequence numArray)
	for i = 1 to length(numArray) do
		numArray[i] = - (numArray[i])
	end for
	return numArray
end function

public function AbsoluteValue(sequence numArray)
	if length(numArray) then
		if numArray[1] < 0 then
			numArray = Negate(numArray)
		end if
	end if
	return numArray
end function

public function Subtract(sequence numArray, AtomRadix radix, Bool isMixed = TRUE)
	if length(numArray) then
		if numArray[1] < 0 then
			numArray = NegativeCarry(numArray, radix)
			if isMixed then
				numArray = NegativeBorrow(numArray, radix)
			end if
		else
			numArray = Carry(numArray, radix)
			if isMixed then
				numArray = Borrow(numArray, radix)
			end if
		end if
	end if
	return numArray
end function


-- Rounding functions:

-- public function TrimLeadingZeros1(sequence numArray)
-- 	for i = 1 to length(numArray) do
-- 		if numArray[i] != 0 then
-- 			if i = 1 then
-- 				return numArray
-- 			else
-- 				return numArray[i..$]
-- 			end if
-- 		end if
-- 	end for
-- 	return {}
-- vend function

public function TrimLeadingZeros(sequence numArray)
	while length(numArray) and numArray[1] = 0 do
		numArray = numArray[2..$]
	end while
	return numArray
end function

-- public function TrimTrailingZeros1(sequence numArray)
-- 	for i = length(numArray) to 1 by -1 do
-- 		if numArray[i] != 0 then
-- 			if i = length(numArray) then
-- 				return numArray
-- 			else
-- 				return numArray[1..i]
-- 			end if
-- 		end if
-- 	end for
-- 	return {}
-- end function

public function TrimTrailingZeros(sequence numArray)
	while length(numArray) and numArray[$] = 0 do
		numArray = numArray[1..$-1]
	end while
	return numArray
end function

public function CarryRadixOnlyEx(sequence numArray, AtomRadix radix, integer way = 1)
	atom b
	integer i
	i = length(numArray)
	while i > 0 do
		b = numArray[i]
		if b != radix then
			exit -- break;
		end if
		numArray[i] = 0 -- modulus, or remainder
		if i = 1 then
			numArray = prepend(numArray, way)
			exit -- break;
		else
			i -= 1
			numArray[i] += way
		end if
	end while
	return numArray
end function

type ThreeOptions(integer i)
	return i >= 0 and i <= 2
end type

public constant noSubtractAdjust = 2

public function AdjustRound(sequence num, integer exponent, PositiveScalar targetLength, AtomRadix radix, ThreeOptions isMixed = TRUE)
	integer oldlen, roundTargetLength, rounded
	atom halfRadix, negHalfRadix, f
	sequence ret
ifdef USE_TASK_YIELD then
	if useTaskYield then
		task_yield()
	end if
end ifdef
if isMixed != noSubtractAdjust then
	oldlen = length(num)
	num = TrimLeadingZeros(num)
	exponent += (length(num) - (oldlen))
	--adjustExponent()
	oldlen = length(num)
	-- in Subtract, the first element of num cannot be a zero.
	num = Subtract(num, radix, isMixed)
	-- use Subtract() when there are both negative and positive numbers.
	-- otherwise, you can use Carry().
	num = TrimLeadingZeros(num)
	exponent += (length(num) - (oldlen))
end if
	rounded = 0
	if length(num) = 0 then
		ret = {{}, exponent, targetLength, radix, rounded}
		return ret
	end if
	if isRoundToZero and exponent < -targetLength then
		ret = {{}, exponent, targetLength, radix, (num[1] < 0) - (num[1] > 0)} -- "rounded"
		return ret
	end if
	-- Round2: num, exponent, targetLength, radix
	if ROUND_TO_NEAREST_OPTION then
		roundTargetLength = exponent + 1 + adjustRound
		if targetLength < roundTargetLength then
			targetLength = roundTargetLength
		end if
		if roundTargetLength <= 1 then
			if exponent <= -1 then
				if exponent = -1 then
					num = {0} & num
				else
					num = {0, 0}
				end if
				exponent = 0 -- zero because it rounds to nearest integer
			end if
			roundTargetLength = 1
		end if
	else
		roundTargetLength = targetLength - (adjustRound)
		if roundTargetLength <= 0 then
			if roundTargetLength = 0 then
				num = {0} & num
				exponent += 1
			else
				num = {0, 0}
				-- exponent = 0 -- don't reset exponent
			end if
			roundTargetLength = 1
		end if
	end if
	halfRadix = floor(radix / 2)
	negHalfRadix = - (halfRadix)
	if length(num) > roundTargetLength then
		if ROUND = ROUND_TRUNCATE then
			num = num[1..roundTargetLength]
			rounded = (num[1] < 0) - (num[1] > 0) -- give the opposite of the sign
		else
			f = num[roundTargetLength + 1]
			if integer(radix) and IsIntegerOdd(radix) then
				-- feature: support for odd radixes
				for i = roundTargetLength + 2 to length(num) do
					if f != halfRadix and f != negHalfRadix then
						exit
					end if
					f = num[i]
				end for
			end if
			if f = halfRadix or f = negHalfRadix then
				if ROUND = ROUND_EVEN then
					halfRadix -= IsIntegerOdd(num[roundTargetLength])
				elsif ROUND = ROUND_ODD then
					halfRadix -= IsIntegerEven(num[roundTargetLength])
				elsif ROUND = ROUND_ZERO then
					f = 0
				end if
			elsif ROUND = ROUND_INF then -- round towards plus(+) and minus(-) infinity
				halfRadix -= 1
			elsif ROUND = ROUND_POS_INF then -- round towards plus(+) infinity
				f += 1
			elsif ROUND = ROUND_NEG_INF then -- round towards minus(-) infinity
				f -= 1
			end if
			num = num[1..roundTargetLength]
			rounded = (halfRadix < f) - (f < negHalfRadix)
			if rounded then
				num[roundTargetLength] += rounded
				num = CarryRadixOnlyEx(num, radix * rounded, rounded)
				exponent += (length(num) - (roundTargetLength))
			else
				rounded = (num[1] < 0) - (num[1] > 0) -- give the opposite of the sign
			end if
		end if
	end if
	num = TrimTrailingZeros(num)
	oldlen = length(num)
	num = TrimLeadingZeros(num)
	exponent += (length(num) - (oldlen))
	ret = {num, exponent, targetLength, radix, rounded}
	return ret
end function


public function MultiplyExp(sequence n1, integer exp1, sequence n2, integer exp2, PositiveScalar targetLength, AtomRadix radix)
	sequence numArray, ret
	numArray = Multiply(n1, n2)
	ret = AdjustRound(numArray, exp1 + exp2, targetLength, radix)
	return ret
end function

public function SquareExp(sequence n1, integer exp1, PositiveScalar targetLength, AtomRadix radix)
	sequence numArray, ret
	numArray = Multiply(n1, n1)
	ret = AdjustRound(numArray, exp1 + exp1, targetLength, radix)
	return ret
end function


public function AddExp(sequence n1, integer exp1, sequence n2, integer exp2, PositiveScalar targetLength, AtomRadix radix)
	sequence numArray, ret
	integer size
	size = (length(n1) - (exp1)) - (length(n2) - (exp2))
	if size < 0 then
		size = - (size)
		n1 = n1 & repeat(0, size)
	elsif 0 < size then
		n2 = n2 & repeat(0, size)
	end if
	if exp1 < exp2 then
		exp1 = exp2
	end if
	numArray = Add(n1, n2)
	ret = AdjustRound(numArray, exp1, targetLength, radix)
	return ret
end function

public function SubtractExp(sequence n1, integer exp1, sequence n2, integer exp2, PositiveScalar targetLength, AtomRadix radix)
	sequence numArray, ret
	integer size
	size = (length(n1) - (exp1)) - (length(n2) - (exp2))
	if size < 0 then
		size = - (size)
		n1 = n1 & repeat(0, size)
	elsif 0 < size then
		n2 = n2 & repeat(0, size)
	end if
	if exp1 < exp2 then
		exp1 = exp2
	end if
	numArray = Subtr(n1, n2)
	ret = AdjustRound(numArray, exp1, targetLength, radix)
	return ret
end function


-- Division and Multiply Inverse:
-- https://en.wikipedia.org/wiki/Newton%27s_method#Multiplyiplicative_inverses_of_numbers_and_power_series

constant two = {2}
PositiveInteger forSmallRadix = 0 -- this number can be 0 or greater

public procedure SetForSmallRadix(PositiveInteger i)
	forSmallRadix = i -- increase this number for smaller radixes
end procedure

public function GetForSmallRadix()
	return forSmallRadix
end function

public function ProtoMultiplicativeInverseExp(sequence guess, integer exp0, sequence den1, integer exp1, PositiveScalar targetLength, AtomRadix radix)
	-- a = guess
	-- n1 = den1
	-- f(a) = a * (2 - n1 * a)
	--
	-- Proof: for f(x) = 1/x
	-- f(a) = 2a - n1*a^2
	-- a = 2a - n1*a^2
	-- 0 = a - n1*a^2
	-- x = a
	-- ax^2 + bx + c = 0
	-- a=(- n1), b=1, c=0
	-- x = (-b +-sqrt(b^2 - 4ac)) / (2a)
	-- x = (-1 +-1) / (-2*n1)
	-- x = 0, 1/n1
	sequence tmp, numArray, ret
	integer exp2
	tmp = MultiplyExp(guess, exp0, den1, exp1, targetLength, radix) -- den1 * a
-- ? tmp -- turns to one
	numArray = tmp[1]
	exp2 = tmp[2]
	tmp = SubtractExp(two, 0, numArray, exp2, targetLength - (forSmallRadix), radix) -- 2 - tmp
-- ? tmp -- turns to one
	numArray = tmp[1]
	exp2 = tmp[2]
	if length(numArray) = 1 then
		if numArray[1] = 1 then
			if exp2 = 0 then
				-- signal_solution_found = 1
				return {guess, exp0}
			end if
		end if
	end if
	ret = MultiplyExp(guess, exp0, numArray, exp2, targetLength, radix) -- a * tmp
-- ? ret -- turns to ans
	return ret
end function


public function IntToDigits(atom x, AtomRadix radix)
	sequence numArray
	atom a
	numArray = {}
	while x != 0 do
		a = remainder(x, radix)
		numArray = {a} & numArray
		x = RoundTowardsZero(x / radix) -- must be Round() to work on negative numbers
	end while
	return numArray
end function

public function ExpToAtom(sequence n1, integer exp1, PositiveScalar targetLength, AtomRadix radix)
	atom p, ans, lookat, ele
	integer overflowBy, len
	if length(n1) = 0 then
		return 0 -- tried to divide by zero
	end if
	-- what if exp1 is too large?
	p = log(radix)
	overflowBy = exp1 - floor(LOG_ATOM_MAX / p) + 2 -- +2 may need to be bigger
	if overflowBy > 0 then
		-- overflow warning in "power()" function
		-- reduce size
		exp1 -= overflowBy
	else
		-- what if exp1 is too small?
		overflowBy = exp1 - floor(LOG_ATOM_MIN / p) - 2 -- -2 may need to be bigger
		if overflowBy < 0 then
			exp1 -= overflowBy
		else
			overflowBy = 0
		end if
	end if
	exp1 -= targetLength
	len = length(n1)
	p = power(radix, exp1)
	ans = n1[1] * p
	for i = 2 to len do
		p = p / radix
		ele = n1[i]
		if ele != 0 then
			lookat = ans
			ans += ele * p
			if ans = lookat then
				exit
			end if
		end if
	end for
	-- if overflowBy is positive, then there was an overflow
	-- overflowBy is an offset of that overflow in the given radix
	return {ans, overflowBy}
end function

public function GetGuessExp(sequence den, integer exp1, integer protoTargetLength, AtomRadix radix)
	sequence guess, tmp
	atom denom, one, ans
	integer overflowBy, len, sigDigits
ifdef BITS64 then
	sigDigits = Ceil(18 / (log(radix) / log(10)))
elsedef
	sigDigits = Ceil(15 / (log(radix) / log(10)))
end ifdef
	if protoTargetLength < sigDigits then
		sigDigits = protoTargetLength
	end if
	len = length(den)
	tmp = ExpToAtom(den, len - 1, sigDigits, radix)
	denom = tmp[1]
	overflowBy = tmp[2]
	one = power(radix, len - 1 - (overflowBy))
	ans = RoundTowardsZero(one / denom)
	guess = IntToDigits(ans, radix) -- works on negative numbers
	-- tmp = AdjustRound(guess, exp1, sigDigits - 1, radix, FALSE)
	-- tmp[3] = protoTargetLength
	return NewEun(guess, exp1, protoTargetLength, radix)
end function

public procedure DefaultDivideByZeroCallBack()
	puts(1, "Error(1):  In MyEuNumber, tried to divide by zero (1/0).  See file: ex.err\n")
	abort(1/0)
end procedure

public integer divideByZeroCallBackId = routine_id("DefaultDivideByZeroCallBack")

public sequence howComplete = {-1, 0}

public function MultiplicativeInverseExp(sequence den1, integer exp1, PositiveScalar targetLength, AtomRadix radix, sequence guess = {})
	sequence tmp, lookat, ret
	integer exp0, protoTargetLength, protoMoreAccuracy
	howComplete = {-1, 0}
	if length(den1) = 0 then
		lastIterCount = 1
		divideByZeroFlag = 1
		call_proc(divideByZeroCallBackId, {})
		return {}
	end if
	if length(den1) = 1 then
		if den1[1] = 1 or den1[1] = -1 then -- optimization
			howComplete = {1, 1}
			lastIterCount = 1
			return {den1, - (exp1), targetLength, radix, 0}
		end if
	end if
	if multInvMoreAccuracy >= 0 then
		protoMoreAccuracy = multInvMoreAccuracy
	elsif calculationSpeed then
		protoMoreAccuracy = Ceil(targetLength / calculationSpeed)
	else
		protoMoreAccuracy = 0 -- changed to 0
	end if
	protoTargetLength = targetLength + protoMoreAccuracy
	exp0 = - (exp1 + 1)
	if length(guess) = 0 then
		tmp = GetGuessExp(den1, exp0, protoTargetLength, radix)
		guess = tmp[1]
	end if
	ret = AdjustRound(guess, exp0, targetLength, radix, FALSE)
	lastIterCount = iter
	for i = 1 to iter do
		tmp = ProtoMultiplicativeInverseExp(guess, exp0, den1, exp1, protoTargetLength, radix)
		guess = tmp[1]
		-- ? {length(guess), protoTargetLength}
		exp0 = tmp[2]
		lookat = ret
		ret = AdjustRound(guess, exp0, targetLength, radix, noSubtractAdjust)
		if length(tmp) = 2 then
			-- solution found
			howComplete = repeat(length(ret[1]), 2)
			lastIterCount = i
			exit
		end if
		if ret[2] = lookat[2] then
			howComplete = Equaln(ret[1], lookat[1])
			if howComplete[1] = howComplete[2] then
			-- if equal(ret[1], lookat[1]) then
				lastIterCount = i
				exit
			end if
		end if
	end for
	if lastIterCount = iter then
		printf(1, "Error:  In MyEuNumber, forSmallRadix is %d, try increasing\n SetForSmallRadix() to a larger integer.  See file: ex.err\n", {forSmallRadix})
		abort(1/0)
	end if
	return ret
end function


public function DivideExp(sequence num1, integer exp1, sequence den2, integer exp2, PositiveScalar targetLength, AtomRadix radix)
	sequence tmp
	if zeroDividedByZeroFlag and length(num1) = 0 and length(den2) = 0 then
		return NewEun({1}, 0, targetLength, radix)
	end if
	tmp = MultiplicativeInverseExp(den2, exp2, targetLength, radix)
	if length(tmp) then
		tmp = MultiplyExp(num1, exp1, tmp[1], tmp[2], targetLength, radix)
		return tmp
	else
		return {}
	end if
end function


public function ConvertExp(sequence n1, integer exp1, PositiveScalar targetLength, AtomRadix fromRadix, AtomRadix toRadix)
	sequence n2, n3, result
	integer exp2, exp3
	n1 = TrimTrailingZeros(n1)
	if length(n1) = 0 then
		result = {{}, 0, targetLength, toRadix, 0}
		return result
	end if
	if length(n1) <= exp1 then
		n1 = n1 & repeat(0, exp1 - length(n1) + 1)
	end if
	n2 = ConvertRadix(n1, fromRadix, toRadix)
	exp2 = length(n2) - 1
	n3 = ConvertRadix({1} & repeat(0, length(n1) - (exp1 + 1)), fromRadix, toRadix)
	exp3 = length(n3) - 1
	result = DivideExp(n2, exp2, n3, exp3, targetLength, toRadix)
	return result
end function


public function IsProperLengthAndRadix(PositiveScalar targetLength = defaultTargetLength, AtomRadix radix = defaultRadix)
	return (targetLength * power(radix - 1, 2) <= DOUBLE_MAX)
-- On 64-bit systems, long double has significand precision of 64 bits: DOUBLE_MAX = (power(2, 64) - 1) -- value: 18446744073709551615
-- On 32-bit systems, double has significand precision of 53 bits: DOUBLE_MAX = (power(2, 53) - 1) -- value: 9007199254740991
end function


-- Eun (type)
public type Eun(object x)
	if sequence(x) then
	if length(x) = 5 then
	if sequence(x[1]) then
	if integer(x[2]) then
	if integer(x[5]) then
	if integer(x[3]) then
	if atom(x[4]) then
		return IsProperLengthAndRadix(x[3], x[4])
	end if
	end if
	end if
	end if
	end if
	end if
	end if
	return 0
end type

public function NewEun(sequence num = {}, integer exp = 0, PositiveScalar targetLength = defaultTargetLength, AtomRadix radix = defaultRadix, integer flags = 0)
	Eun x = {num, exp, targetLength, radix, flags}
	return x
end function

public function EunAdjustRound(Eun n1, integer adjustBy = -1)
	if length(n1[1]) = 0 then
		return n1
	end if
	if adjustBy != -1 then
		integer tmp
		sequence s
		tmp = adjustRound
		adjustRound = adjustBy
		s = AdjustRound(n1[1], n1[2], n1[3], n1[4])
		adjustRound = tmp
		return s
	end if
	return AdjustRound(n1[1], n1[2], n1[3], n1[4])
end function

public function RemoveLastDigits(Eun n1, PositiveInteger digits = 1)
	n1[1] = n1[1][1..$-digits]
	return n1
end function

-- EunMultiply
public function EunMultiply(Eun n1, Eun n2)
	PositiveScalar targetLength
	if n1[4] != n2[4] then
		puts(1, "Error(5):  In MyEuNumber, radixes do not equal.  See file: ex.err\n")
		abort(1/0)
	end if
	if n1[3] > n2[3] then
		targetLength = n1[3]
	else
		targetLength = n2[3]
	end if
	return MultiplyExp(n1[1], n1[2], n2[1], n2[2], targetLength, n1[4])
end function

public function EunSquare(Eun n1)
	return SquareExp(n1[1], n1[2], n1[3], n1[4])
end function

-- EunAdd
public function EunAdd(Eun n1, Eun n2)
	PositiveScalar targetLength
	if n1[4] != n2[4] then
		puts(1, "Error(5):  In MyEuNumber, radixes do not equal.  See file: ex.err\n")
		abort(1/0)
	end if
	if n1[3] > n2[3] then
		targetLength = n1[3]
	else
		targetLength = n2[3]
	end if
	return AddExp(n1[1], n1[2], n2[1], n2[2], targetLength, n1[4])
end function
-- EunSum
public function EunSum(sequence data)
	Eun sum
	sum = NewEun()
	for i = 1 to length(data) do
		sum = EunAdd(sum, data[i])
	end for
	return sum
end function
-- EunNegate
public function EunNegate(Eun n1)
	n1[1] = Negate(n1[1])
	return n1
end function
-- EunAbsoluteValue
public function EunAbsoluteValue(Eun n1)
	n1[1] = AbsoluteValue(n1[1])
	return n1
end function
-- EunSubtract
public function EunSubtract(Eun n1, Eun n2)
	PositiveScalar targetLength
	if n1[4] != n2[4] then
		puts(1, "Error(5):  In MyEuNumber, radixes do not equal.  See file: ex.err\n")
		abort(1/0)
	end if
	if n1[3] > n2[3] then
		targetLength = n1[3]
	else
		targetLength = n2[3]
	end if
	return SubtractExp(n1[1], n1[2], n2[1], n2[2], targetLength, n1[4])
end function
-- EunMultiplicativeInverse
public function EunMultiplicativeInverse(Eun n1, sequence guess = {})
	return MultiplicativeInverseExp(n1[1], n1[2], n1[3], n1[4], guess)
end function
-- EunDivide
public function EunDivide(Eun n1, Eun n2)
	PositiveScalar targetLength
	if n1[4] != n2[4] then
		puts(1, "Error(5):  In MyEuNumber, radixes do not equal.  See file: ex.err\n")
		abort(1/0)
	end if
	if n1[3] > n2[3] then
		targetLength = n1[3]
	else
		targetLength = n2[3]
	end if
	return DivideExp(n1[1], n1[2], n2[1], n2[2], targetLength, n1[4])
end function
-- EunConvert
public function EunConvert(Eun n1, atom toRadix, PositiveScalar targetLength)
	return ConvertExp(n1[1], n1[2], targetLength, n1[4], toRadix)
end function

integer equalLength = 0

public function CompareExp(sequence n1, integer exp1, sequence n2, integer exp2)
-- It doesn't look at targetLength or radix, so they should be the same.
-- still fixing, Fixed for negative values.
	integer minlen, f
	-- Case of zero (0)
	equalLength = 0
	if length(n1) = 0 then
		if length(n2) = 0 then
			return 0
		end if
		return iff(n2[1] > 0, -1, 1)
	end if
	if length(n2) = 0 then
		return iff(n1[1] > 0, 1, -1)
	end if
	-- Case of unequal signs (mismatch of signs, sign(n1) xor sign(n2))
	if n1[1] > 0 then
		if n2[1] < 0 then
			return 1
		end if
		-- both positive
		if exp1 != exp2 then
			return (exp1 > exp2) - (exp1 < exp2)
		end if
	else
		if n2[1] > 0 then
			return -1
		end if
		-- both negative
		if exp1 != exp2 then
			return (exp1 < exp2) - (exp1 > exp2)
		end if
	end if
	-- exponents and signs are the same:
	if length(n1) > length(n2) then
		n2 = n2 & {0} -- use zero as "sentinel" last digit
		minlen = length(n2)
	elsif length(n1) < length(n2) then
		n1 = n1 & {0} -- use zero as "sentinel" last digit
		minlen = length(n1)
	else
		minlen = length(n1)
	end if
	for i = 1 to minlen do
		f = (n1[i] > n2[i]) - (n1[i] < n2[i])
		if f then
			return f
		end if
		equalLength += 1
	end for
	return 0 -- numbers are equal
end function

public function GetEqualLength()
	return equalLength
end function

public function EunCompare(Eun n1, Eun n2)
	if n1[4] != n2[4] then
		return {}
	end if
	return CompareExp(n1[1], n1[2], n2[1], n2[2])
end function

public function EunReverse(Eun n1) -- reverse endian
	n1[1] = reverse(n1[1])
	return n1
end function

public function EunFracPart(Eun n1)
	integer len
	if n1[2] >= 0 then
		len = n1[2] + 1
		if len >= length(n1[1]) then
			n1[1] = {}
			n1[2] = 0
		else
			n1[1] = n1[1][len + 1..$]
			n1[2] = -1
		end if
	end if
	return n1
end function

public function EunIntPart(Eun n1)
	integer len
	len = n1[2] + 1
	if len < length(n1[1]) then
		if n1[2] < 0 then
			n1[1] = {}
			n1[2] = 0
		else
			n1[1] = n1[1][1..len]
		end if
	end if
	return n1
end function

public function EunRoundSig(Eun n1, PositiveScalar sigDigits = defaultTargetLength)
	PositiveScalar targetLength
	targetLength = n1[3]
	n1 = AdjustRound(n1[1], n1[2], sigDigits, n1[4])
	n1[3] = targetLength
	return n1
end function

public function EunRoundSignificantDigits(Eun n1, PositiveScalar sigDigits = defaultTargetLength)
	return EunRoundSig(n1, sigDigits)
end function

public function EunRoundToInt(Eun n1) -- Round to nearest integer
	if n1[2] < -1 then
		n1[1] = {}
		n1[2] = 0
	else
		n1 = EunRoundSig(n1, n1[2] + 1)
	end if
	return n1
end function

type UpOneRange(integer i)
	return i <= 1 and i >= -1
end type

public function EunCombInt(Eun n1, integer adjustBy = -1, UpOneRange upOne = 0) -- upOne should be: 1, 0, or -1
-- if there is any fraction part, add or subtract one, away from zero,
-- or add one towards positive infinity, if "up = 1"
	integer len, exponent
	n1 = EunAdjustRound(n1, adjustBy)
	len = length(n1[1])
	if len != 0 then
		exponent = n1[2]
		n1 = EunIntPart(n1)
		if exponent < 0 or exponent + 1 < len then
			-- add one, same sign
			if upOne = 0 then
				if n1[1][1] < 0 then
					upOne = -1
				else
					upOne = 1
				end if
			end if
			n1 = AddExp(n1[1], n1[2], {upOne}, 0, n1[3], n1[4])
		end if
	end if
	return n1
end function

public function EunModf(Eun fp)
-- similar to C's "modf()"
	return {EunIntPart(fp), EunFracPart(fp)}
end function

public function EunfDiv(Eun num, Eun den)
-- similar to C's "div()"
	-- returns quotient and remainder
	Eun div
	div = EunModf(EunDivide(num, den))
	div[2] = EunMultiply(div[2], den)
	return div
end function

public function EunfMod(Eun num, Eun den)
-- similar to C's "fmod()", just the "mod" or remainder
	return EunMultiply(EunFracPart(EunDivide(num, den)), den)
end function

--numio.e:

-- Compression functions to store an "Eun" in memory:

public function ToMemory(sequence n1)
	integer offset
	atom ma
	sequence n2
	if not Eun(n1) then
		n1 = ToEun(n1)
	end if
	n2 = EunConvert(n1, 256, 1 + Ceil(n1[3] * (log(n1[4]) / log(256))))
	n1[1] = length(n2[1])
	n1[2] = n2[2]
	n2 = n2[1]
	if length(n2) then
		if n2[1] < 0 then
			n1[3] = -n1[3] -- store sign information
			n2 = Negate(n2)
		end if
	end if
ifdef BITS64 then
	offset = 3 * 8 + 10
	ma = allocate_data(length(n2) + offset)
	if ma = 0 then
		return 0 -- couldn't allocate data
	end if
	poke8(ma, n1[1..3])
	poke(ma + 3 * 8, atom_to_float80(n1[4]))
	poke(ma + offset, n2)
elsedef
	offset = 3 * 4 + 8
	ma = allocate_data(length(n2) + offset)
	if ma = 0 then
		return 0 -- couldn't allocate data
	end if
	poke4(ma, n1[1..3])
	poke(ma + 3 * 4, atom_to_float64(n1[4]))
	poke(ma + offset, n2)
end ifdef
	return ma
end function

public function FromMemoryToEun(atom ma)
	sequence n1, n2
ifdef BITS64 then
	n1 = peek8s({ma, 3}) & float80_to_atom(peek({ma + 3 * 8, 8}))
	n2 = peek({ma + 3 * 8 + 10, n1[1]})
elsedef
	n1 = peek4s({ma, 3}) & float64_to_atom(peek({ma + 3 * 4, 8}))
	n2 = peek({ma + 3 * 4 + 8, n1[1]})
end ifdef
	if n1[3] < 0 then
		-- signed
		n1[3] = -n1[3]
		n2 = Negate(n2)
	end if
	n2 = NewEun(n2, n1[2], Ceil(n1[3] * (log(n1[4]) / log(256))), 256)
	n1 = EunConvert(n2, n1[4], n1[3])
	return n1
end function

public procedure FreeMemory(atom ma)
	free(ma)
end procedure

-- atom ma
-- 
-- adjustRound = 1
-- ma = ToMemory("-0.01234")
-- puts(1, ToString(FromMemoryToEun(ma)))
-- 
-- FreeMemory(ma)

public function ToString(object d)
-- converts an Eun or an atom to a string.
	if atom( d ) then
		-- dont change these:
ifdef BITS64 then
		if remainder( d, 1 ) or d >= 1e18 or d <= -1e18 then
			return sprintf( "%.17e", d ) -- 1e18, 17 is one less
		else
			return sprintf( "%d", d ) -- can only do 18 decimal places for 80-bit, or 15 for 64-bit doubles
		end if
elsedef
		if remainder( d, 1 ) or d >= 1e15 or d <= -1e15 then
			return sprintf( "%.14e", d ) -- 1e15, 14 is one less
		else
			return sprintf( "%d", d ) -- can only do 18 decimal places for 80-bit, or 15 for 64-bit doubles
		end if
end ifdef
	else
		sequence st
		integer f, len
		if sequence( d[1] ) then
			if d[4] != 10 then
				d = EunConvert( d, 10, Ceil((log(d[4]) / log(10)) * d[3]) )
			end if
			st = d[1]
			len = length( st )
			if len = 0 then
				return "0"
			end if
			if st[1] < 0 then
				f = 1
				-- st = -st
				for i = 1 to len do
					st[i] = - (st[i])
				end for
			else
				f = 0
			end if
			-- st += '0'
			for i = 1 to len do
				st[i] += '0'
			end for
			if f then
				st = "-" & st
			end if
		else
			if d[1] = 1 then -- (+infinity)
				return "inf"
			elsif d[1] = -1 then -- (-infinity)
				return "-inf"
			end if
		end if
		f = (st[1] = '-')
		f += 1 -- f is now 1 or 2
		if length( st ) > f then
			st = st[1..f] & "." & st[f+1..length(st)]
		end if
		st = st & "e" & ToString( d[2] )
		return st
	end if
end function

-- converts to a floating point number
-- takes a string or a "Eun"
public function ToAtom(sequence s)
	if Eun(s) then
	--if length(d) and sequence(d[1]) then
		s = ToString(s)
	end if
	s = value( s )
	if s[1] = GET_SUCCESS and atom(s[2]) then
		return s[2]
	end if
	return {} -- return empty sequence on error.
end function

public function StringToNumberExp(sequence st)
	integer isSigned, exp, f
	sequence ob
	if length(st) = 0 then
		return 0 -- undefined
	end if
	isSigned = ('-' = st[1])
	if isSigned or '+' = st[1] then
		st = st[2..length(st)]
	end if
	if equal(st, "inf") then
		-- returns values for +inf (1) and -inf (-1)
		if isSigned then
			return {-1, 0} -- represents negative infinity
		else
			return {1, 0} -- represents positive infinity
		end if
	end if
	f = find('e', st)
	if f = 0 then
		f = find('E', st)
	end if
	if f then
		ob = st[f+1..length(st)]
		ob = value( ob )
		if ob[1] != GET_SUCCESS then
			return 2 -- error in value() function
		end if
		exp = ob[2]
		st = st[1..f-1]
	else
		exp = 0
	end if
	while length(st) and st[1] = '0' do
		st = st[2..length(st)]
	end while
	f = find('.', st)
	if f then
		st = st[1..f - 1] & st[f + 1..length(st)]
		exp += (f - 2) -- 2 because f starts at 1. (1 if f starts at 0)
	else
		exp += (length(st) - 1)
	end if
	while length(st) and st[1] = '0' do
		exp -= 1
		st = st[2..length(st)]
	end while
	if length(st) = 0 then
		exp = 0
	end if
	-- st -= '0'
	for i = 1 to length(st) do
		st[i] -= '0'
		if st[i] > 9 or st[i] < 0 then
			return {0, 0}
		end if
	end for
	if isSigned then
		st = Negate(st)
	end if
	return {st, exp}
end function

public function ToEun(object s, AtomRadix radix = defaultRadix, PositiveScalar targetLength = defaultTargetLength)
-- Dropping support for atoms, use strings instead (strings are more accurate)
	if atom(s) then
		s = ToString(s)
	end if
	s = StringToNumberExp(s)
	s = s & {Ceil((log(radix) / log(10)) * targetLength), 10, 0}
	if atom(s[1]) then
		return s
	end if
	if radix != 10 then
		s = EunConvert(s, radix, targetLength)
	end if
	return s
end function

--nthroot.e

-- NthRoot algorithm

-- Find the nth root of any number

-- Example: square root

-- ? EunNthRoot(2, {{1, 8}, 1, 100, 10}, {{4, 2}, 0, 100, 10})

public Bool realMode = TRUE

public procedure SetRealMode(Bool i)
	realMode = i
end procedure
public function GetRealMode()
	return realMode
end function

public function IntPowerExp(PositiveInteger toPower, sequence n1, integer exp1, 
			      PositiveScalar targetLength, AtomRadix radix)
-- b^x = e^(x * ln(b))
	sequence p
	if toPower = 0 then
		return {{1}, 0, targetLength, radix, 0}
	end if
	p = {n1, exp1}
	for i = 2 to toPower do
		p = MultiplyExp(p[1], p[2], n1, exp1, targetLength, radix)
	end for
	return p
end function

-- function NthRoot(object x, object guess, object n)
--      object quotient, average
--      quotient = x / power(guess, n-1)
--      average = (quotient + ((n-1) * guess)) / n
--      return average
-- end function

public function NthRootProtoExp(PositiveScalar n, sequence x1, integer x1Exp,
				   sequence guess, integer guessExp, 
				   PositiveScalar targetLength, AtomRadix radix)
	sequence p, quot, average
	p = IntPowerExp(n - 1, guess, guessExp, targetLength, radix)
	quot = DivideExp(x1, x1Exp, p[1], p[2], targetLength, radix)
	p = MultiplyExp({n - 1}, 0, guess, guessExp, targetLength, radix)
	p = AddExp(p[1], p[2], quot[1], quot[2], targetLength, radix)
	average = DivideExp(p[1], p[2], {n}, 0, targetLength, radix)
	return average
end function

public PositiveOption nthRootMoreAccuracy = -1 -- if -1, then use calculationSpeed

public procedure SetNthRootMoreAccuracy(PositiveOption i)
	nthRootMoreAccuracy = i
end procedure
public function GetNthRootMoreAccuracy()
	return nthRootMoreAccuracy
end function

public integer nthRootIter = 1000000000
public integer lastNthRootIter = -1

public sequence nthRootHowComplete = {-1, 0}

public function NthRootExp(PositiveScalar n, sequence x1, integer x1Exp, sequence guess, 
			integer guessExp, PositiveScalar targetLength, AtomRadix radix)
	sequence tmp, lookat, ret
	integer protoTargetLength, moreAccuracy
	nthRootHowComplete = {-1, 0}
	if length(x1) = 0 then
		nthRootHowComplete = {0, 0}
		lastNthRootIter = 1
		return {x1, x1Exp, targetLength, radix, 0}
	end if
	if length(x1) = 1 then
		if x1[1] = 1 or x1[1] = -1 then
			nthRootHowComplete = {1, 1}
			lastNthRootIter = 1
			return {x1, x1Exp, targetLength, radix, 0}
		end if
	end if
	if nthRootMoreAccuracy >= 0 then
		moreAccuracy = nthRootMoreAccuracy
	elsif calculationSpeed then
		moreAccuracy = Ceil(targetLength / calculationSpeed)
	else
		moreAccuracy = 0 -- changed to 0
	end if
	protoTargetLength = targetLength + moreAccuracy
	ret = AdjustRound(guess, guessExp, targetLength, radix, FALSE)
	lastNthRootIter = nthRootIter
	for i = 1 to nthRootIter do
		tmp = NthRootProtoExp(n, x1, x1Exp, guess, guessExp, protoTargetLength, radix)
		guess = tmp[1]
		guessExp = tmp[2]
		lookat = ret
		ret = AdjustRound(guess, guessExp, targetLength, radix, noSubtractAdjust)
		if ret[2] = lookat[2] then
			nthRootHowComplete = Equaln(ret[1], lookat[1])
			if nthRootHowComplete[1] = nthRootHowComplete[2] then
			-- if equal(ret[1], lookat[1]) then
				lastNthRootIter = i
				exit
			end if
		end if
	end for
	if lastNthRootIter = nthRootIter then
		puts(1, "Error(4):  In MyEuNumber, too many iterations.  Unable to calculate number.\n  See file: ex.err\n")
		abort(1/0)
	end if
	return ret
end function

public procedure DefaultRealModeErrorCallBack()
	puts(1, "Error(2):  In MyEuNumber, in real mode, even root of -1, i.e. sqrt(-1).\n  See file: ex.err\n")
	abort(1/0)
end procedure

public integer realModeErrorCallBackId = routine_id("DefaultRealModeErrorCallBack")

public function EunNthRoot(PositiveScalar n, Eun n1, object option = {})
	Eun guess
	object tmp
	PositiveScalar targetLength, isImag, exp1, f
	sequence ret
	atom a
	exp1 = 0
	if atom(option) or length(option) = 0 then
		-- Latest code:
		exp1 = n1[2]
		f = remainder(exp1, n)
		if f then
			exp1 -= f
			if exp1 <= 0 then
				exp1 += n
			end if
		end if
		n1[2] -= exp1
		tmp = ToAtom(n1)
		a = tmp
		f = 0
		if a < 0 then
			-- factor out sqrt(-1), an imaginary number, on even roots
			a = -a -- atom
			f = IsIntegerOdd(n)
		end if
		a = power(a, 1 / n)
		if f then
			a = -a -- atom
		end if
		tmp = ToEun(a, n1[4], n1[3])
		guess = tmp
	else
		guess = option
	end if
	if n1[4] != guess[4] then
		puts(1, "Error(5):  In MyEuNumber, radixes do not equal.  See file: ex.err\n")
		abort(1/0)
	end if
	if n1[3] > guess[3] then
		targetLength = n1[3]
	else
		targetLength = guess[3]
	end if
	if IsIntegerEven(n) then
		if length(n1[1]) and n1[1][1] < 0 then
			if realMode then
				call_proc(realModeErrorCallBackId, {})
			end if
			-- factor out sqrt(-1)
			isImag = 1
			n1[1] = Negate(n1[1])
		else
			isImag = 0
		end if
		if IsNegative(guess[1]) then
			guess[1] = Negate(guess[1])
		end if
	end if
	ret = NthRootExp(n, n1[1], n1[2], guess[1], guess[2], targetLength, n1[4])
	exp1 = floor(exp1 / n)
	ret[2] += exp1
	if IsIntegerOdd(n) then
		return ret
	else
		return {isImag, ret, EunNegate(ret)}
	end if
end function

public function EunSquareRoot(Eun n1, object guess = {})
-- Set "realMode" variable to TRUE (or 1), if you want it to crash if supplied a negative number.
-- Use "isImag" to determine if the result is complex, 
-- which will happen if a negative number is passed to this function.
	return EunNthRoot(2, n1, guess)
end function

public function EunCubeRoot(Eun n1, object guess = {})
	return EunNthRoot(3, n1, guess)
end function

public function EunSqrt(Eun n1)
	object tmp
	sequence guess, ret
	integer exp
	atom a
	exp = n1[2]
	-- factor out a perfect square, of a power of radix, an even number
	if IsIntegerOdd(exp) then
		if exp > 0 then
			exp -= 1
		else
			exp += 1
		end if
	end if
	n1[2] -= exp
	tmp = ToAtom(n1)
	a = tmp
	if a < 0 then
		-- factor out sqrt(-1), an imaginary number
		a = -a -- atom
	end if
	a = sqrt(a)
	tmp = ToEun(a, n1[4], n1[3])
	guess = tmp
	ret = EunSquareRoot(n1, guess)
	exp = floor(exp / 2)
	ret[2][2] += exp
	ret[3][2] += exp
	-- returns isImag for if imaginary, and two answers: {one positive, one negative}
	return ret
end function

--mymath.e

-- MyMath: My Additions to myEunumber.

-- Experimental

-- this number should be calculated by the program:

-- Use GetPI() and GetE() instead.

-- public Eun EunPI = {"31415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679" - '0', 0, 100, 10, 0}
-- public Eun EunE  = {"2718281828459045235360287471352662497757247093699959574966967627724076630353547594571382178525166427" - '0', 0, 100, 10, 0}

-- Begin ArcTan():

public PositiveOption arcTanMoreAccuracy = -1 -- if -1, then use calculationSpeed

public procedure SetArcTanMoreAccuracy(PositiveOption i)
	arcTanMoreAccuracy = i
end procedure
public function GetArcTanMoreAccuracy()
	return arcTanMoreAccuracy
end function

public integer arcTanIter = 1000000000
public integer arcTanCount = -1

public sequence arcTanHowComplete = {-1, 0}

public function ArcTanExp(sequence n1, integer exp1, PositiveScalar targetLength, AtomRadix radix)
	sequence sum, a, b, c, d, e, f, tmp, count, xSquared, xSquaredPlusOne, lookat, ret
	integer protoTargetLength, moreAccuracy
	arcTanHowComplete = {-1, 0}
	if arcTanMoreAccuracy >= 0 then
		moreAccuracy = arcTanMoreAccuracy
	elsif calculationSpeed then
		moreAccuracy = Ceil(targetLength / calculationSpeed)
	else
		moreAccuracy = 0 -- changed to 0
	end if
	protoTargetLength = targetLength + moreAccuracy
	-- First iteration:
	-- x*x + 1
	e = MultiplyExp(n1,exp1,n1,exp1,protoTargetLength,radix)
	e = AddExp(e[1],e[2],{1},0,protoTargetLength,radix)
	-- x/e
	sum = DivideExp(n1,exp1,e[1],e[2],protoTargetLength,radix)
	a = {{1}, 0}
	b = {{1}, 0}
	c = {{1}, 0}
	count = {{1}, 0}
	d = {n1,exp1}
	xSquared = MultiplyExp(n1,exp1,n1,exp1,protoTargetLength,radix)
	xSquaredPlusOne = AddExp(xSquared[1],xSquared[2],{1},0,protoTargetLength,radix)
	e = xSquaredPlusOne
	-- Second iteration(s):
	ret = AdjustRound(sum[1], sum[2], targetLength, radix, FALSE)
	arcTanCount = arcTanIter
	for n = 1 to arcTanIter do
		a = MultiplyExp(a[1], a[2], {4}, 0, protoTargetLength, radix)
		tmp = AdjustRound({n}, 0, protoTargetLength, radix, FALSE)
		b = MultiplyExp(b[1], b[2], tmp[1], tmp[2], protoTargetLength, radix)
		tmp = MultiplyExp(b[1], b[2], b[1], b[2], protoTargetLength, radix)
		-- it needs these statements:
		count = AddExp(count[1], count[2], {1}, 0, protoTargetLength, radix)
		c = MultiplyExp(c[1], c[2], count[1], count[2], protoTargetLength, radix)
		count = AddExp(count[1], count[2], {1}, 0, protoTargetLength, radix)
		c = MultiplyExp(c[1], c[2], count[1], count[2], protoTargetLength, radix)
		d = MultiplyExp(d[1], d[2], xSquared[1], xSquared[2], protoTargetLength, radix)
		e = MultiplyExp(e[1], e[2], xSquaredPlusOne[1], xSquaredPlusOne[2], protoTargetLength, radix)
		f = MultiplyExp(a[1], a[2], tmp[1], tmp[2], protoTargetLength, radix)
		f = DivideExp(f[1], f[2], c[1], c[2], protoTargetLength, radix)
		f = MultiplyExp(f[1], f[2], d[1], d[2], protoTargetLength, radix)
		f = DivideExp(f[1], f[2], e[1], e[2], protoTargetLength, radix)
		sum = AddExp(sum[1], sum[2], f[1], f[2], protoTargetLength, radix)
		lookat = ret
		ret = AdjustRound(sum[1], sum[2], targetLength, radix, noSubtractAdjust)
		if ret[2] = lookat[2] then
			arcTanHowComplete = Equaln(ret[1], lookat[1])
			if arcTanHowComplete[1] = arcTanHowComplete[2] then
			-- if equal(ret[1], lookat[1]) then
				arcTanCount = n
				exit
			end if
		end if
	end for
	if arcTanCount = arcTanIter then
		puts(1, "Error(4):  In MyEuNumber, too many iterations.  Unable to calculate number.\n  See file: ex.err\n")
		abort(1/0)
	end if
	return ret
end function

public function EunArcTan(Eun a)
	return ArcTanExp(a[1], a[2], a[3], a[4])
end function

-- End ArcTan().

sequence quarterPI
quarterPI = repeat(0, 4)
public function GetQuarterPI(PositiveScalar targetLength = defaultTargetLength, AtomRadix radix = defaultRadix, PositiveInteger multBy = 1)
	if quarterPI[3] != targetLength or quarterPI[4] != radix then
		quarterPI = ArcTanExp({1}, 0, targetLength, radix)
	end if
	if multBy != 1 then
		return EunMultiply(quarterPI, NewEun({multBy}, 0, targetLength, radix))
	end if
	return quarterPI
end function
public function GetHalfPI(PositiveScalar targetLength = defaultTargetLength, integer radix = defaultRadix)
	return GetQuarterPI(targetLength, radix, 2)
end function
public function GetPI(PositiveScalar targetLength = defaultTargetLength, integer radix = defaultRadix)
	return GetQuarterPI(targetLength, radix, 4)
end function


public integer ExpExp1Iter = 1000
public sequence exp1HowComplete = {-1, 0}

public function ExpExp1(sequence n1, integer exp1, PositiveScalar targetLength, AtomRadix radix)
-- not quite accurate enough for large numbers.

-- it doesn't like large numbers.

-- does work for negative numbers.
-- using taylor series
--https://en.wikipedia.org/wiki/TaylorSeries
--My algorithm:
--      integer maxIter = 100
--      atom x, sum, tmp
--      x = 1
--      sum = 1
--      for i = maxIter to 1 by -1 do
--              tmp = (x/i)
--              sum *= tmp
--              sum += 1
--      end for
--      return sum
--end My algorithm.
	sequence sum, tmp, den
	exp1HowComplete = {-1, 0}
	sum = {{1}, 0}
	den = {{ExpExp1Iter + 1}, 0}
	for i = ExpExp1Iter to 1 by -1 do
		den = AddExp(den[1], den[2], {-1}, 0, targetLength, radix)
		tmp = DivideExp(n1, exp1, den[1], den[2], targetLength, radix)
		sum = MultiplyExp(sum[1], sum[2], tmp[1], tmp[2], targetLength, radix)
		sum = AddExp(sum[1], sum[2], {1}, 0, targetLength, radix)
		exp1HowComplete = {i, ExpExp1Iter}
	end for
	return sum
end function

public function EunExp1(Eun a)
	return ExpExp1(a[1], a[2], a[3], a[4])
end function

public function Exponentiation(atom u, integer m)
	atom q, prod, current
	q = m
	prod = 1
	current = u
	if q > 0 then
		while q > 0 do
			if remainder(q, 2) = 1 then
				prod *= current
				q -= 1
			end if
			current *= current
			q /= 2
		end while
	else
		while q < 0 do
			if remainder(q, 2) = -1 then
				prod /= current
				q += 1
			end if
			current *= current
			q /= 2
		end while
	end if
	return prod
end function

-- atom E = 2.7182818284590452353602874713527
-- ? Exponentiation(E, 20) -- answer is 485165195.4
-- ? Exponentiation(E, -21) -- answer is 7.582560428e-10

public function Remainder2Exp(sequence n1, integer exp1)
-- returns 1 or 0
	integer n
	n = exp1 + 1 -- reminder.
	if n < 1 then
		return 0
	end if
	if n > length(n1) then
		return 0
	end if
	return IsIntegerOdd(n1[n])
end function

public sequence expWholeHowComplete = {0, -1}

public function EunExpWhole(Eun u, Eun m)
-- exp function for whole numbers
	Eun q, prod, current
	PositiveScalar targetLength, radix
	expWholeHowComplete = {0, -1}
	targetLength = m[3]
	radix = m[4]
	if u[4] != radix then
		current = EunConvert(u, radix, targetLength)
	else
		current = u
		current[3] = targetLength
	end if
	q = m
	prod = {{1}, 0, targetLength, radix, 0}
	if CompareExp(q[1], q[2], {}, 0) = 1 then
		while CompareExp(q[1], q[2], {}, 0) = 1 do
			expWholeHowComplete = {q[2], -1}
			if Remainder2Exp(q[1], q[2]) = 1 then
				prod = EunMultiply(prod, current)
				q = AddExp({-1}, 0, q[1], q[2], targetLength, radix)
			end if
			current = EunMultiply(current, current)
			q = DivideExp(q[1], q[2], {2}, 0, targetLength, radix)
		end while
	else
		while CompareExp(q[1], q[2], {}, 0) = -1 do
			expWholeHowComplete = {q[2], -1}
			if Remainder2Exp(q[1], q[2]) = -1 then
				prod = EunDivide(prod, current)
				q = AddExp({1}, 0, q[1], q[2], targetLength, radix)
			end if
			current = EunMultiply(current, current)
			q = DivideExp(q[1], q[2], {2}, 0, targetLength, radix)
		end while
	end if
	return prod
end function

public PositiveOption expMoreAccuracy = -1 -- if -1, then use calculationSpeed

public procedure SetExpMoreAccuracy(PositiveOption i)
	expMoreAccuracy = i
end procedure
public function GetExpMoreAccuracy()
	return expMoreAccuracy
end function

public integer expExpIter = 1000000000
public integer expExpCount = -1

public sequence expHowComplete = {-1, 0}

public function ExpExp(sequence n1, integer exp1, PositiveScalar targetLength, AtomRadix radix)
-- it doesn't like large numbers.
-- so, factor
-- 
--      e^(a+b) <=> e^(a) * e^(b)
--      e^(whole+frac) <=> EunExpWhole(E,whole) * EunExp(fract)
-- 
-- using taylor series
--https://en.wikipedia.org/wiki/TaylorSeries
--
-- -- exp(1) = sum of k=0 to inf (1/k!)
-- 
-- atom x
-- x = 1
-- 
-- atom sum, num, den
-- num = 1
-- den = 1
-- sum = 1
-- for i = 1 to 100 do
--      num *= x
--      den *= i
--      sum += ( num / den )
-- end for
-- 
-- ? sum
	sequence num, den, sum, tmp, lookat, ret
	integer protoTargetLength, moreAccuracy
	expHowComplete = {-1, 0}
	if expMoreAccuracy >= 0 then
		moreAccuracy = expMoreAccuracy
	elsif calculationSpeed then
		moreAccuracy = Ceil(targetLength / calculationSpeed)
	else
		moreAccuracy = 0 -- changed to 0
	end if
	protoTargetLength = targetLength + moreAccuracy
	num = {{1}, 0}
	den = {{1}, 0}
	sum = {{1}, 0}
	ret = NewEun({1}, 0, targetLength, radix)
	expExpCount = expExpIter
	for i = 1 to expExpIter do
		num = MultiplyExp(num[1], num[2], n1, exp1, protoTargetLength, radix)
		den = MultiplyExp(den[1], den[2], {i}, 0, protoTargetLength, radix)
		tmp = DivideExp(num[1], num[2], den[1], den[2], protoTargetLength, radix)
		sum = AddExp(sum[1], sum[2], tmp[1], tmp[2], protoTargetLength, radix)
		lookat = ret
		ret = AdjustRound(sum[1], sum[2], targetLength, radix, noSubtractAdjust)
		if ret[2] = lookat[2] then
			expHowComplete = Equaln(ret[1], lookat[1])
			if expHowComplete[1] = expHowComplete[2] then -- how equal are they? Use tasks to report on how close we are to the answer.
			-- if equal(ret[1], lookat[1]) then
				expExpCount = i
				exit
			end if
		end if
	end for
	if expExpCount = expExpIter then
		puts(1, "Error(4):  In MyEuNumber, too many iterations.  Unable to calculate number.\n  See file: ex.err\n")
		abort(1/0)
	end if
	return ret
end function

sequence eunE
eunE = repeat(0, 4)
public function GetE(PositiveScalar targetLength = defaultTargetLength, AtomRadix radix = defaultRadix)
	if eunE[3] != targetLength or eunE[4] != radix then
		eunE = ExpExp({1}, 0, targetLength, radix)
	end if
	return eunE
end function


public function EunExp(Eun n1)
-- 
-- ExpExp() doesn't like large numbers.
-- so, factor
-- 
--      e^(a+b) <=> e^(a) * e^(b)
--      e^(whole+frac) <=> EunExpWhole(E,whole) * EunExp(fract)
-- 
	-- get the whole and fractional parts of the number:
	sequence num, frac, whole, decimal, ret
	integer exp1, size, more, isNeg
	more = 0 -- this number may need to be changed, has to be zero or greater
	exp1 = n1[2]
	size = exp1 + 1
	num = n1[1]
	-- factor out (-1), use MultiplicativeInverse (1/x) later
	isNeg = IsNegative(num)
	if isNeg then
		num = Negate(num)
	end if
	frac = n1
	frac[1] = num
	num = frac
	if size >= 1 then
		if size < length(n1[1]) then
			num[1] = num[1][1..size]
			frac[1] = frac[1][size + 1..$]
			frac[2] = -1
		else
			frac = {}
		end if
		num[3] += more -- targetLength += 1
		whole = EunExpWhole(GetE(num[3], num[4]), num)
		num = {}
	else
		whole = {}
	end if
	if length(frac) then
		frac[3] += more -- targetLength += 1
		decimal = ExpExp(frac[1], frac[2], frac[3], frac[4])
		if length(whole) then
			ret = EunMultiply(whole, decimal)
		else
			ret = decimal
		end if
	else
		ret = whole
	end if
	ret[3] -= more -- targetLength -= 1
	ret = AdjustRound(ret[1], ret[2], ret[3], ret[4], noSubtractAdjust)
	if isNeg then
		ret = EunMultiplicativeInverse(ret)
	end if
	return ret
end function

-- ? EunExp(NewEun({-2}, 0))

public integer ExpExpFastIter = 1 -- try to keep this number small.

public function GetExpFastIter()
	return ExpExpFastIter
end function

public procedure SetExpFastIter(integer i)
	ExpExpFastIter = i
end procedure

public sequence expFastHowComplete = {-1, 0}

public function ExpExpFast(sequence x1, integer exp1, sequence y2, integer exp2, PositiveScalar targetLength, AtomRadix radix)
-- e^(x/y) = 1 + 2x/(2y-x+x^2/(6y+x^2/(10y+x^2/(14y+x^2/(18y+x^2/(22y+...
	-- precalculate:
	-- 1, 2x, x, x^2, 4y, (2 + 4i)y
	-- i = targetLength to 0.
	-- Subtract 4y
	sequence xSquared, fourY, targetLengthY, tmp
	expFastHowComplete = {-1, 0}
	xSquared = MultiplyExp(x1, exp1, x1, exp1, targetLength, radix)
	fourY = MultiplyExp({-4}, 0, y2, exp2, targetLength, radix)
	targetLengthY = MultiplyExp({2 + 4 * ExpExpFastIter}, 0, y2, exp2, targetLength, radix)
	tmp = targetLengthY
	for i = ExpExpFastIter to 2 by -1 do
		tmp = DivideExp(xSquared[1], xSquared[2], tmp[1], tmp[2], targetLength, radix)
		targetLengthY = AddExp(targetLengthY[1], targetLengthY[2], fourY[1], fourY[2], targetLength, radix)
		tmp = AddExp(tmp[1], tmp[2], targetLengthY[1], targetLengthY[2], targetLength, radix)
		expFastHowComplete = {i, 0}
	end for
	tmp = DivideExp(xSquared[1], xSquared[2], tmp[1], tmp[2], targetLength, radix)
	tmp = AddExp(tmp[1], tmp[2], -x1, exp1, targetLength, radix)
	tmp = AddExp(tmp[1], tmp[2], y2 * 2, exp2, targetLength, radix)
	tmp = DivideExp(x1 * 2, exp1, tmp[1], tmp[2], targetLength, radix)
	tmp = AddExp({1}, 0, tmp[1], tmp[2], targetLength, radix)
	expFastHowComplete = {1, 0}
	return tmp
end function

public function EunExpFast(Eun numerator, Eun denominator)
-- e^(x/y) = 1 + 2x/(2y-x+x^2/(6y+x^2/(10y+x^2/(14y+x^2/(18y+x^2/(22y+...
	PositiveScalar targetLength
	if numerator[4] != denominator[4] then
		puts(1, "Error(5):  In MyEuNumber, radixes do not equal.  See file: ex.err\n")
		abort(1/0)
	end if
	if numerator[3] > denominator[3] then
		targetLength = numerator[3]
	else
		targetLength = denominator[3]
	end if
	object tmp0, tmp1
	tmp1 = ExpExpFast(numerator[1], numerator[2], denominator[1], denominator[2], targetLength, numerator[4])
	while 1 do
		tmp0 = tmp1
		ExpExpFastIter *= 2
		tmp1 = ExpExpFast(numerator[1], numerator[2], denominator[1], denominator[2], targetLength, numerator[4])
		if tmp1[2] = tmp0[2] then
			expFastHowComplete = Equaln(tmp1[1], tmp0[1])
			if expFastHowComplete[1] = expFastHowComplete[2] then
				exit
			end if
		end if
	end while
	ExpExpFastIter /= 2
	return tmp1
end function

public PositiveOption logMoreAccuracy = -1 -- if -1, then use calculationSpeed

public procedure SetLogMoreAccuracy(PositiveOption i)
	logMoreAccuracy = i
end procedure
public function GetLogMoreAccuracy()
	return logMoreAccuracy
end function

public integer logIter = 1000000000 -- 50
public integer logIterCount = -1

public sequence logHowComplete = {-1, 0}

public function LogExp(sequence n1, integer exp1, sequence guess, integer exp0, PositiveScalar targetLength, AtomRadix radix)
	-- ln(x) = y[n] = y[n - 1] + 2 * (x - exp(y[n - 1]))/(x + exp(y[n - 1]))
	sequence expY, xMinus, xPlus, tmp, lookat, ret, one
	integer protoTargetLength, moreAccuracy
	logHowComplete = {-1, 0}
	one = NewEun({1}, 0, protoTargetLength, radix)
	if logMoreAccuracy >= 0 then
		moreAccuracy = logMoreAccuracy
	elsif calculationSpeed then
		moreAccuracy = Ceil(targetLength / calculationSpeed)
	else
		moreAccuracy = 0 -- changed to 0
	end if
	protoTargetLength = targetLength + moreAccuracy
	guess = NewEun(guess, exp0, protoTargetLength, radix)
	ret = guess
	logIterCount = logIter
	for i = 1 to logIter do
		-- guess = guess + 2 * (num1 - exp(guess))/(num1 + exp(guess))
		expY = EunExpFast(guess, one)
		--expY = EunExp({guess[1], guess[2], protoTargetLength, radix, 0})
		xPlus = AddExp(n1, exp1, expY[1], expY[2], protoTargetLength, radix)
		xMinus = AddExp(n1, exp1, Negate(expY[1]), expY[2], protoTargetLength, radix)
		tmp = DivideExp(xMinus[1], xMinus[2], xPlus[1], xPlus[2], protoTargetLength, radix)
		tmp = MultiplyExp({2}, 0, tmp[1], tmp[2], protoTargetLength, radix)
		guess = AddExp(guess[1], guess[2], tmp[1], tmp[2], protoTargetLength, radix)
		lookat = ret
		ret = AdjustRound(guess[1], guess[2], targetLength, radix, noSubtractAdjust)
		if ret[2] = lookat[2] then
			logHowComplete = Equaln(ret[1], lookat[1])
			if logHowComplete[1] = logHowComplete[2] then
			-- if equal(ret[1], lookat[1]) then
				logIterCount = i
				exit
			end if
		end if
	end for
	if logIterCount = logIter then
		puts(1, "Error(4):  In MyEuNumber, too many iterations.  Unable to calculate number.\n  See file: ex.err\n")
		abort(1/0)
	end if
	return ret
end function

public function EunLog(Eun n1)
	object tmp
	sequence guess, ret
	integer isImag
	atom a
	tmp = ToAtom(n1)
	a = tmp
	if a < 0 then
		-- result would be an imaginary number (imag == i)
		-- ln(-1) = PI * i
		-- ln(-a) = ln(a) + (PI * i)
		isImag = 1
		a = -a -- atom
		n1[1] = Negate(n1[1])
	else
		isImag = 0
	end if
	a = log(a) -- it makes a guess
	tmp = ToEun(a)
	guess = tmp
	if n1[4] != guess[4] then
		guess = EunConvert(guess, n1[4], n1[3])
	end if
	ret = LogExp(n1[1], n1[2], guess[1], guess[2], n1[3], n1[4])
	if isImag then
		return {ret, GetPI(ret[3], ret[4])}
	else
		return ret
	end if
end function

--BEGIN TRIG FUNCTIONS:

--function RadiansToDegrees(r)
--      return r * 90 / halfPI
--end function
--function DegreesToRadians(d)
--      return d * halfPI / 90
--end function

public function EunRadiansToDegrees(Eun r)
	Eun ninety = NewEun({9}, 1, r[3], 10)
	if r[4] != 10 then
		ninety = EunConvert(ninety, r[4], r[3])
	end if
	return EunMultiply(EunDivide(r, GetHalfPI(r[3], r[4])), ninety)
end function
public function EunDegreesToRadians(Eun d)
	Eun ninety = NewEun({9}, 1, d[3], 10)
	if d[4] != 10 then
		ninety = EunConvert(ninety, d[4], d[3])
	end if
	return EunMultiply(EunDivide(d, ninety), GetHalfPI(d[3], d[4]))
end function

-- Using Newton's method:
-- 
-- "sin"
-- sine(x) = x - ((x^3)/(3!)) + ((x^5)/(5!)) - ((x^7)/(7!)) + ((x^9)/(9!)) - ...
-- 
-- cos(x)  = 1 - ((x^2)/(2!)) + ((x^4)/(4!)) - ((x^6)/(6!)) + ((x^8)/(8!)) - ...
-- 
-- 
-- 
-- tan(x) = sine(x) / cos(x)
-- 
-- csc(x) = 1 / sine(x)
-- sec(x) = 1 / cos(x)
-- cot(x) = cos(x) / sine(x)
-- 
-- "atan"
-- arctan(x) = x - ((x^3)/3) + ((x^5)/5) - ((x^7)/7) + ..., where abs(x) < 1
-- 
-- 
-- 
-- use: cos() for calculating
-- 
-- 
-- what about tan()?
-- 
-- tan(x) = sine(x) / cos(x)
-- 
-- End comments.


-- !!! Remember to use Radians (Rad) on these functions !!!

public PositiveOption sinMoreAccuracy = -1 -- if -1, then use calculationSpeed

public procedure SetSinMoreAccuracy(PositiveOption i)
	sinMoreAccuracy = i
end procedure
public function GetSinMoreAccuracy()
	return sinMoreAccuracy
end function

public integer sinIter = 1000000000 -- 500
public integer sinIterCount = -1

public function IsPositiveOdd(integer i)
    return and_bits(i, 1)
end function
public function IsPositiveEven(integer i)
    return and_bits(i, 0)
end function

public sequence trigHowComplete = {-1, 0} -- for sin() and cos()

public function SinExp(sequence n1, integer exp1, PositiveScalar targetLength, AtomRadix radix)
-- sine(x) = x - ((x^3)/(3!)) + ((x^5)/(5!)) - ((x^7)/(7!)) + ((x^9)/(9!)) - ...
	-- Cases: 0 equals zero (0)
	-- Range: -PI/2 to PI/2, inclusive
	sequence ans, a, b, tmp, xSquared, lookat, ret
	integer step, protoTargetLength, moreAccuracy
	if length(n1) = 0 then
		trigHowComplete = {0, 0}
		return NewEun({}, exp1, targetLength, radix)
	end if
	trigHowComplete = {-1, 0}
	if sinMoreAccuracy >= 0 then
		moreAccuracy = sinMoreAccuracy
	elsif calculationSpeed then
		moreAccuracy = Ceil(targetLength / calculationSpeed)
	else
		moreAccuracy = 0 -- changed to 0
	end if
	protoTargetLength = targetLength + moreAccuracy
	step = 1 -- SinExp() uses 1
	xSquared = MultiplyExp(n1, exp1, n1, exp1, protoTargetLength, radix)
	a = {n1, exp1} -- a is the numerator, SinExp() starts with x.
	b = {{1}, 0} -- b is the denominator.
	-- copy x to ans:
	ans = a -- in SinExp(), ans starts with x.
	ret = AdjustRound(ans[1], ans[2], targetLength, radix, FALSE)
	sinIterCount = sinIter
	for i = 1 to sinIter do -- start at 1 for all computer languages.
		-- first step is 3, for SinExp()
		step += 2
		tmp = MultiplyExp({step - 1}, 0, {step}, 0, protoTargetLength, radix)
		b = MultiplyExp(b[1], b[2], tmp[1], tmp[2], protoTargetLength, radix)
		a = MultiplyExp(a[1], a[2], xSquared[1], xSquared[2], protoTargetLength, radix)
		tmp = DivideExp(a[1], a[2], b[1], b[2], protoTargetLength, radix)
		if IsPositiveOdd(i) then
			-- Subtract
			tmp[1] = Negate(tmp[1])
		end if
		ans = AddExp(ans[1], ans[2], tmp[1], tmp[2], protoTargetLength, radix)
		lookat = ret
		ret = AdjustRound(ans[1], ans[2], targetLength, radix, noSubtractAdjust)
		if ret[2] = lookat[2] then
			trigHowComplete = Equaln(ret[1], lookat[1])
			if trigHowComplete[1] = trigHowComplete[2] then
			-- if equal(ret[1], lookat[1]) then
				sinIterCount = i
				exit
			end if
		end if
	end for
	if sinIterCount = sinIter then
		puts(1, "Error(4):  In MyEuNumber, too many iterations.  Unable to calculate number.\n  See file: ex.err\n")
		abort(1/0)
	end if
	return ans
end function

-- !!! Remember to use Radians (Rad) on these functions !!!

public PositiveOption cosMoreAccuracy = -1 -- if -1, then use calculationSpeed

public procedure SetCosMoreAccuracy(PositiveOption i)
	cosMoreAccuracy = i
end procedure
public function GetCosMoreAccuracy()
	return cosMoreAccuracy
end function

public integer cosIter = 1000000000 -- 500
public integer cosIterCount = -1

public function CosExp(sequence n1, integer exp1, PositiveScalar targetLength, AtomRadix radix)
-- cos(x) = 1 - ((x^2)/(2!)) + ((x^4)/(4!)) - ((x^6)/(6!)) + ((x^8)/(8!)) - ...
	-- Range: -PI/2 to PI/2, exclusive
	sequence ans, a, b, tmp, xSquared, lookat, ret
	integer step, protoTargetLength, moreAccuracy
	trigHowComplete = {-1, 0}
	if cosMoreAccuracy >= 0 then
		moreAccuracy = cosMoreAccuracy
	elsif calculationSpeed then
		moreAccuracy = Ceil(targetLength / calculationSpeed)
	else
		moreAccuracy = 0 -- changed to 0
	end if
	protoTargetLength = targetLength + moreAccuracy
	step = 0 -- CosExp() uses 0
	xSquared = MultiplyExp(n1, exp1, n1, exp1, protoTargetLength, radix)
	a = {{1}, 0} -- a is the numerator, CosExp() starts with 1.
	b = {{1}, 0} -- b is the denominator.
	-- copy "1" to ans:
	ans = a -- in CosExp(), ans starts with 1.
	ret = AdjustRound(ans[1], ans[2], targetLength, radix, FALSE)
	cosIterCount = cosIter
	for i = 1 to cosIter do -- start at 1 for all computer languages.
		-- first step is 2, for CosExp()
		step += 2
		tmp = MultiplyExp({step - 1}, 0, {step}, 0, protoTargetLength, radix)
		b = MultiplyExp(b[1], b[2], tmp[1], tmp[2], protoTargetLength, radix)
		a = MultiplyExp(a[1], a[2], xSquared[1], xSquared[2], protoTargetLength, radix)
		tmp = DivideExp(a[1], a[2], b[1], b[2], protoTargetLength, radix)
		if IsPositiveOdd(i) then
			-- Subtract
			tmp[1] = Negate(tmp[1])
		end if
		ans = AddExp(ans[1], ans[2], tmp[1], tmp[2], protoTargetLength, radix)
		lookat = ret
		ret = AdjustRound(ans[1], ans[2], targetLength, radix, noSubtractAdjust)
		if ret[2] = lookat[2] then
			trigHowComplete = Equaln(ret[1], lookat[1])
			if trigHowComplete[1] = trigHowComplete[2] then
			-- if equal(ret[1], lookat[1]) then
				cosIterCount = i
				exit
			end if
		end if
	end for
	if cosIterCount = cosIter then
		puts(1, "Error(4):  In MyEuNumber, too many iterations.  Unable to calculate number.\n  See file: ex.err\n")
		abort(1/0)
	end if
	return ans
end function

-- EunSin:

public function EunSin(Eun x)
-- To find sin(x):
-- y = x mod PI
-- if y >= -PI/2 and y <= PI/2 then
--  r = sin(y)
-- else
--  if y < 0 then
--   r = -cos(y + PI/2)
--  else
--   r = cos(y - PI/2)
--  end if
-- end if
-- return r
	sequence y, half_pi, one_pi
	half_pi = GetHalfPI(x[3], x[4])
	one_pi = GetPI(x[3], x[4])
	y = EunfMod(x, one_pi)
	if EunCompare(y, half_pi) <= 0 then
		if EunCompare(y, EunNegate(half_pi)) >= 0 then
			return SinExp(y[1], y[2], y[3], y[4])
		end if
	end if
	if IsNegative(y[1]) then
		y = EunAdd(y, half_pi)
		y = CosExp(y[1], y[2], y[3], y[4])
		y = EunNegate(y)
	else
		y = EunSubtract(y, half_pi)
		y = CosExp(y[1], y[2], y[3], y[4])
	end if
	return y
end function

-- EunCos:

public function EunCos(Eun x)
-- To find cos(x):
-- y = abs(x) mod (2*PI)
-- if y < PI then
--  r = cos(y)
-- else
--  r = sin(y - (3/2)*PI)
-- end if
-- return r
	sequence y, half_pi, var_pi
	y = x
	half_pi = GetHalfPI(y[3], y[4])
	var_pi = EunMultiply(half_pi, NewEun({4}, 0, y[3], y[4]))
	y[1] = AbsoluteValue(y[1])
	y = EunfMod(y, var_pi) -- y = abs(x) mod 2*pi
	var_pi = EunMultiply(half_pi, NewEun({2}, 0, y[3], y[4]))
	if EunCompare(y, var_pi) < 0 then -- if (y < pi) then
		return CosExp(y[1], y[2], y[3], y[4])
	else
		-- return sin(y - (3/2)*pi)
		var_pi = EunMultiply(half_pi, NewEun({3}, 0, y[3], y[4]))
		y = EunSubtract(y, var_pi)
		return SinExp(y[1], y[2], y[3], y[4])
	end if
end function

-- Tangent

public function EunTan(Eun a)
	return EunDivide(EunSin(a), EunCos(a))
end function

-- !!! Remember to use Radians (Rad) on these functions !!!

--https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
--INCOMPLETE: arcSin and arcTan are experimental for now.

--                  1*z^3     1*3*z^5     1*3*5*z^7
-- arcsin(z) = z + (-----) + (-------) + (---------) + ...
--                   2* 3      2*4* 5      2*4*6* 7

-- Pattern: (1,2,3) ; (1,2,3,4,5) ; (1,2,3,4,5,6,7) ; (1,2,3,4,5,6,7,8,9)
-- odds on top, evens on bottom, except for the latest odd value.

--Note: Too slow?

public PositiveOption arcSinMoreAccuracy = -1 -- if -1, then use calculationSpeed

public procedure SetArcSinMoreAccuracy(PositiveOption i)
	arcSinMoreAccuracy = i
end procedure
public function GetArcSinMoreAccuracy()
	return arcSinMoreAccuracy
end function

public integer arcSinIter = 1000000000
public integer arcSinIterCount = -1

public sequence arcSinHowComplete = {-1, 0}

public function ArcSinExp(sequence n1, integer exp1, PositiveScalar targetLength, AtomRadix radix)
--something wrong with arcsin()?
-- arcsin(z) = z + (1/2)(z^3/3) + (1*3/(2*4))(z^5/5) + (1*3*5/(2*4*6))(z^7/7) + ...
	sequence sum, xSquared, top, bottom, odd, even, x, tmp, lookat, ret
	integer protoTargetLength, moreAccuracy
	arcSinHowComplete = {-1, 0}
	if arcSinMoreAccuracy >= 0 then
		moreAccuracy = arcSinMoreAccuracy
	elsif calculationSpeed then
		moreAccuracy = Ceil(targetLength / calculationSpeed)
	else
		moreAccuracy = 0 -- changed to 0
	end if
	protoTargetLength = targetLength + moreAccuracy
	sum = {n1, exp1}
	x = {n1, exp1}
	xSquared = MultiplyExp(n1, exp1, n1, exp1, targetLength, radix)
	bottom = {{2}, 0}
	odd = {{3}, 0}
	-- First iteration:
	tmp = MultiplyExp(bottom[1], bottom[2], odd[1], odd[2], targetLength, radix)
	x = MultiplyExp(x[1], x[2], xSquared[1], xSquared[2], targetLength, radix)
	tmp = DivideExp(x[1], x[2], tmp[1], tmp[2], targetLength, radix)
	sum = AddExp(sum[1], sum[2], tmp[1], tmp[2], targetLength, radix)
	-- Second iteration(s):
	top = {{1}, 0}
	even = {{2}, 0}
	ret = sum
	arcSinIterCount = arcSinIter
	for n = 1 to arcSinIter do
		even = AddExp(even[1], even[2], {2}, 0, protoTargetLength, radix)
		bottom = MultiplyExp(bottom[1], bottom[2], even[1], even[2], protoTargetLength, radix)
		top  = MultiplyExp(top[1], top[2], odd[1], odd[2], protoTargetLength, radix)
		odd = AddExp(odd[1], odd[2], {2}, 0, protoTargetLength, radix)
		tmp = MultiplyExp(bottom[1], bottom[2], odd[1], odd[2], protoTargetLength, radix)
		x = MultiplyExp(x[1], x[2], xSquared[1], xSquared[2], protoTargetLength, radix)
		tmp = DivideExp(x[1], x[2], tmp[1], tmp[2], protoTargetLength, radix)
		tmp = MultiplyExp(tmp[1], tmp[2], top[1], top[2], protoTargetLength, radix)
		sum = AddExp(sum[1], sum[2], tmp[1], tmp[2], protoTargetLength, radix)
		lookat = ret
		ret = AdjustRound(sum[1], sum[2], targetLength, radix, noSubtractAdjust)
		if ret[2] = lookat[2] then
			arcSinHowComplete = Equaln(ret[1], lookat[1])
			if arcSinHowComplete[1] = arcSinHowComplete[2] then
			-- if equal(ret[1], lookat[1]) then
				arcSinIterCount = n
				exit
			end if
		end if
	end for
	if arcSinIterCount = arcSinIter then
		puts(1, "Error(4):  In MyEuNumber, too many iterations.  Unable to calculate number.\n  See file: ex.err\n")
		abort(1/0)
	end if
	return ret
end function

public function EunArcSin(Eun a)
-- arcsin(z) = z + (1/2)(z^3/3) + (1*3/(2*4))(z^5/5) + (1*3*5/(2*4*6))(z^7/7) + ...
	return ArcSinExp(a[1],a[2],a[3],a[4])
end function

public function EunArcCos(Eun a)
-- arccos(x) = arcsin(1) - arcsin(x)
-- arccos(x) = (EunPi / 2) - arcsin(x)
	return EunSubtract(GetHalfPI(a[3], a[4]), EunArcSin(a))
end function

-- EunArcTan, function is coded above.

-- Method 1:
-- 
--             +inf      (-1)^n * z^(2*n+1)
-- arctan(z) = sumation( ------------------- )
--             n=0       (2*n+1)
-- 
-- for: [abs(z) <= 1, z != i, z != -i]

--HERE, code method 1, TODO!

-- 
-- 
-- ArctanExp funtion: (Method 2)
-- 
--             +inf      (2^(2*n)) * ((n!)^2) * (z^(2*n+1))
-- arctan(z) = sumation( ---------------------------------- )
--             n=0       ((2*n+1)!) * ((1+z^2)^(n+1))
-- 
-- function Myfactorial(integer f)
--      atom y
--      y = 1
--      --for i = 1 to f do
--      for i = 2 to f do
--              y *= i
--      end for
--      return y
-- end function
-- integer MyarctanIter = 80
-- function Myarctan(atom x)
--      atom sum, a, b, c, d, e, f
--      sum = x / (1 + x*x)
--      for n = 1 to MyarctanIter do
--              --a = power(2,2*n) -- [0]=1, [1]=4, [2]=16, [3]=64, [4]=256, [5]=1024, [6]=4096, [7]=16384, [8]=65536, [9]=262144, [10]=1048576,
--              a = power(4,n)
--              b = Myfactorial(n)
--              b *= b
--              c = Myfactorial(2*n + 1) -- [0]=1, [1]=6, [2]=120, [3]=5040, [4]=362880, [5]=39916800,
--              d = power(x, 2*n + 1) -- equals: x * power(x,2*n)
--              e = power(1 + x*x, n + 1) -- precalculate: (1 + x*x)
--              f = a * b
--              f = f / c
--              f = f * d
--              f = f / e
--              sum += f
--      end for
--      return sum
-- end function

-- Comments: Slow, and inaccurate.

--Next one to work on:

-- ArctanExp, using continued fractions:

-- Status: Not done yet.

-- This method for arctan function is Too slow:

-- public integer arctanIter = 1000000000 -- 500
-- public integer lastIterCountArctan = -1
-- 
-- public function ArctanExp(sequence n1, integer exp1, PositiveScalar targetLength, integer radix)
-- -- works best with small numbers.
-- -- arctan(x) = x - ((x^3)/3) + ((x^5)/5) - ((x^7)/7) + ..., where abs(x) < 1
-- -- sine(x) = x - ((x^3)/(3!)) + ((x^5)/(5!)) - ((x^7)/(7!)) + ((x^9)/(9!)) - ...
--      sequence ans, a, b, tmp, xSquared, lookat
--      --integer step
--      --step = 1 -- SinExp() uses 1
--      xSquared = MultiplyExp(n1, exp1, n1, exp1, targetLength, radix)
--      
--      a = {n1, exp1} -- a is the numerator, SinExp() starts with x.
--      b = {{1}, 0} -- b is the denominator.
--      
--      -- copy x to ans:
--      ans = a -- in SinExp(), ans starts with x.
--      for i = 1 to arctanIter do -- start at 1 for all computer languages.
--              lookat = ans
--              -- first step is 3, for SinExp()
--              --step += 2
--              --tmp = MultiplyExp({step-1}, 0, {step}, 0, targetLength, radix)
--              --b = MultiplyExp(b[1], b[2], tmp[1], tmp[2], targetLength, radix)
--              b = AddExp(b[1], b[2], {2}, 0, targetLength, radix)
--              --b = {{step}, 0} -- "b" is "step" in arctan()
--              
--              a = MultiplyExp(a[1], a[2], xSquared[1], xSquared[2], targetLength, radix)
--              tmp = DivideExp(a[1], a[2], b[1], b[2], targetLength, radix)
--              
--              if IsPositiveOdd(i) then
--                      -- Subtract
--                      tmp[1] = Negate(tmp[1])
--              end if
--              
--              ans = AddExp(ans[1], ans[2], tmp[1], tmp[2], targetLength, radix)
--              if length(ans[1]) > targetLength then
--                      ans[1] = ans[1][1..targetLength]
--              end if
--              if equal(ans, lookat) then
--                      lastIterCountArctan = i
--                      exit -- break
--              end if
--      end for
--      
--      return ans
-- end function


-- More Trig functions:

-- sine = opp/hyp
-- cos = adj/hyp
-- tan = opp/adj
-- 
-- csc = hyp/opp
-- sec = hyp/adj
-- cot = adj/opp

public function EunCsc(Eun a)
	return EunMultiplicativeInverse(EunSin(a))
end function

public function EunSec(Eun a)
	return EunMultiplicativeInverse(EunCos(a))
end function

public function EunCot(Eun a)
	return EunMultiplicativeInverse(EunTan(a))
end function


public function EunArcCsc(Eun a)
	return EunArcSin(EunMultiplicativeInverse(a))
end function

public function EunArcSec(Eun a)
	return EunArcCos(EunMultiplicativeInverse(a))
end function

public function EunArcCot(Eun a)
	integer f
	sequence tmp
	f = CompareExp(a[1], a[2], {}, 0)
	if f = 0 then
		return GetHalfPI(a[3], a[4])
	end if
	tmp = EunArcTan(EunMultiplicativeInverse(a))
	if f < 0 then
		tmp = EunAdd(tmp, GetPI(a[3], a[4]))
	end if
	return tmp
end function

-- Hyperbolic functions:

public function EunSinh(Eun a)
-- sinh(x) = (e^(x) - e^(-x)) / 2
	return EunDivide(EunSubtract(EunExp(a), EunExp(EunNegate(a))), NewEun({2}, 0, a[3], a[4]))
end function

public function EunCosh(Eun a)
-- cosh(x) = (e^(x) + e^(-x)) / 2
	return EunDivide(EunAdd(EunExp(a), EunExp(EunNegate(a))), NewEun({2}, 0, a[3], a[4]))
end function

public function EunTanh(Eun a)
-- tanh(x) = e^(2*x) => a; (a - 1) / (a + 1)
	sequence tmp, local
	local = NewEun({2}, 0, a[3], a[4])
	tmp = EunExp(EunMultiply(a, local))
	local[1] = {1}
	return EunDivide(EunSubtract(tmp, local), EunAdd(tmp, local))
end function

public function EunCoth(Eun a)
-- coth(x) = x != 0; 1 / tanh(x)
	if not CompareExp(a[1], a[2], {}, 0) then
		puts(1, "Error(7):  In MyEuNumber, trig functions: Invalid number passed to\n \"EunCoth()\", cannot be zero (0).\n  See file: ex.err\n")
		abort(1/0)
	end if
	return EunMultiplicativeInverse(EunTanh(a))
end function

public function EunSech(Eun a)
-- sech(x) = 1 / cosh(x)
	return EunMultiplicativeInverse(EunCosh(a))
end function

public function EunCsch(Eun a)
-- csch(x) = x != 0; 1 / sinh(x)
	if not CompareExp(a[1], a[2], {}, 0) then
		puts(1, "Error(7):  In MyEuNumber, trig functions: Invalid number passed to\n \"EunCsch()\", cannot be zero (0).\n  See file: ex.err\n")
		abort(1/0)
	end if
	return EunMultiplicativeInverse(EunSinh(a))
end function

-- See also:
-- https://en.wikipedia.org/wiki/Inverse_hyperbolic_functions

public function EunArcSinh(Eun a)
-- arcsinh(x) = ln(x + sqrt(x^2 + 1))
	sequence tmp
	tmp = EunSqrt(EunAdd(EunMultiply(a, NewEun({2}, 0, a[3], a[4])), NewEun({1}, 0, a[3], a[4])))
	if tmp[1] then
		puts(1, "Error(7):  In MyEuNumber, EunArcSinh(): error, encountered imaginary number,\n something went wrong internally.\n  See file: ex.err\n")
		abort(1/0)
	end if
	return EunLog(EunAdd(a, tmp[2]))
end function

public function EunArcCosh(Eun a)
-- arccosh(x) = x >= 1; ln(x + sqrt(x^2 - 1))
	sequence tmp
	if CompareExp(a[1], a[2], {1}, 0) = -1 then
		puts(1, "Error(7):  In MyEuNumber, trig functions: Invalid number passed to\n \"EunArcCosh()\", cannot be zero (0).\n  See file: ex.err\n")
		abort(1/0)
	end if
	tmp = EunSqrt(EunSubtract(EunMultiply(a, NewEun({2}, 0, a[3], a[4])), NewEun({1}, 0, a[3], a[4])))
	if tmp[1] then
		puts(1, "Error(7):  In MyEuNumber, EunArcCosh(): error, encountered imaginary number,\n something went wrong internally.\n  See file: ex.err\n")
		abort(1/0)
	end if
	return EunLog(EunAdd(a, tmp[2]))
end function

public function EunArcTanh(Eun a)
-- arctanh(x) = abs(x) < 1; ln((1 + x)/(1 - x)) / 2
	sequence tmp, local
	if CompareExp(AbsoluteValue(a[1]), a[2], {1}, 0) >= 0 then
		puts(1, "Error(7):  In MyEuNumber, EunArcTanh(): supplied number is out of domain/range\n  See file: ex.err\n")
		abort(1/0)
	end if
	local = NewEun({1}, 0, a[3], a[4])
	tmp = EunDivide(EunAdd(local, a), EunSubtract(local, a))
	local[1] = {2}
	return EunDivide(EunLog(tmp), local)
end function

public function EunArcCoth(Eun a)
-- arccoth(x) = abs(x) > 1; ln((x + 1)/(x - 1)) / 2
	sequence tmp, local
	if CompareExp(AbsoluteValue(a[1]), a[2], {1}, 0) <= 0 then
		puts(1, "Error(7):  In MyEuNumber, EunArcCoth(): supplied number is out of domain/range\n  See file: ex.err\n")
		abort(1/0)
	end if
	local = NewEun({1}, 0, a[3], a[4])
	tmp = EunDivide(EunAdd(a, local), EunSubtract(a, local))
	local[1] = {2}
	return EunDivide(EunLog(tmp), local)
end function

public function EunArcSech(Eun a)
-- arcsech(x) = 0 < x <= 1; 1 / x => a; ln(a + sqrt(a^2 - 1)) :: ln((1 + sqrt(1 - x^2)) / x)
	sequence tmp, s
	if CompareExp(a[1], a[2], {}, 0) <= 0 or CompareExp(a[1], a[2], {1}, 0) = 1 then
		puts(1, "Error(7):  In MyEuNumber, EunArcSech(): supplied number is out of domain/range\n  See file: ex.err\n")
		abort(1/0)
	end if
	tmp = EunMultiplicativeInverse(a)
	s = EunSqrt(EunSubtract(EunMultiply(tmp, tmp), NewEun({1}, 0, a[3], a[4])))
	return EunLog(EunAdd(tmp, s[2]))
end function

public function EunArcCsch(Eun a)
-- arccsch(x) = x != 0; 1 / x => a; ln(a + sqrt(a^2 + 1))
	sequence tmp, s
	if not length(a[1]) then
		puts(1, "Error(7):  In MyEuNumber, EunArcCsch(): supplied number is out of domain/range\n  See file: ex.err\n")
		abort(1/0)
	end if
	tmp = EunMultiplicativeInverse(a)
	s = EunSqrt(EunAdd(EunMultiply(tmp, tmp), NewEun({1}, 0, a[3], a[4])))
	return EunLog(EunAdd(tmp, s[2]))
end function


--END TRIG FUNCTIONS.

--triangulation.e

-- Triangulation using two (2) points

-- Given: angle A, angle B, distance D (distance between angles A and B)
-- Find distance E and F, (from angle A and B), to intersect point.
-- C is a temporary value.

-- Proof:
-- NOTE: uses all positive numbers
--
-- define:
-- observer at point A, angle A from distance D
-- observer at point B, angle B from distance D
-- distance D between point A and point B
-- distance E coming from angle A
-- distance F coming from angle B
-- height G at right angles (tangent) to distance D
-- X^2 <=> X*X
--
-- G <=> E * sin(A) <=> F * sin(B)
-- divide one by the other, equalling value of one (1)
-- ratio: F / E == sin(A) / sin(B)
-- F == E * sin(A) / sin(B)
-- Pythagorean Theorem:
-- D^2 = E^2 + F^2
-- E == sqrt(D^2 - F^2)
-- D^2 == E^2 + (E * sin(A) / sin(B))^2
-- D^2 == E^2 + E^2 * (sin(A) / sin(B))^2
-- D^2 == E^2 * (1 + (sin(A) / sin(B))^2)
-- E == sqrt(D^2 / (1 + (sin(A) / sin(B))^2))
-- ratio inverted for "F":
-- F == sqrt(D^2 / (1 + (sin(B) / sin(A))^2))
--
-- End of Proof

type WhichOnes(integer i)
	return i >= 1 and i <= 3
end type

public function EunTriangulation(Eun angleA, Eun angleB, Eun distance, WhichOnes whichOnes = 3)
	Eun dsquared, sa, sb
	sequence s, tmp
	integer mode
	if IsNegative(angleA[1]) or IsNegative(angleB[1]) or IsNegative(distance[1]) then
		puts(1, "Error(3):  In MyEuNumber, negative argument(s) in \"EunTriangulation()\".\n  See file: ex.err\n")
		abort(1/0)
	end if
	mode = realMode
	realMode = TRUE
	sa = EunSin(angleA)
	sb = EunSin(angleB)
	dsquared = EunSquare(distance)
	s = {0, 0}
	if and_bits(whichOnes, 1) then
		tmp = EunSqrt(
			EunDivide(
				dsquared,
				EunAdd({{1}, 0, angleA[3], angleA[4]}, EunSquare(EunDivide(sa, sb)))
			)
		)
		s[1] = tmp[2]
	end if
	if and_bits(whichOnes, 2) then
		tmp = EunSqrt(
			EunDivide(
				dsquared,
				EunAdd({{1}, 0, angleA[3], angleA[4]}, EunSquare(EunDivide(sb, sa)))
			)
		)
		s[2] = tmp[2]
	end if
	realMode = mode
	return s
end function


--myeuroots.e

-- Find roots (or zeros) of an equation.

public function MyCompareExp(sequence n1, integer exp1, sequence n2, integer exp2)
	return CompareExp(n1, exp1, n2, exp2)
end function

public sequence delta = {{1},-10}
--public sequence delta = {{1},-80}
--0.0000000001 -- must be a positive number

public procedure SetDelta(integer exp1)
	delta[2] = exp1
end procedure

public function GetDelta()
	return delta[2]
end function

public integer eurootsAdjustRound = 3

public procedure SetEurootsAdjustRound(PositiveInteger i)
	eurootsAdjustRound = i
end procedure

public function GetEurootsAdjustRound()
	return eurootsAdjustRound
end function


-- findRoot private variables:
sequence a, b, c, d, fa, fb, fc, s, fs, tmp, tmp1, tmp2
integer mflag, lookatIter
integer comp1, comp2

function Condition1Thru_5(PositiveScalar len, AtomRadix radix)
	sequence sb, bc, cd
	
	--tmp1 = ((3 * a) + b) / 4
	tmp1 = MultiplyExp({3}, 0, a[1], a[2], len, radix)
	tmp1 = AddExp(tmp1[1], tmp1[2], b[1], b[2], len, radix)
	tmp1 = DivideExp(tmp1[1], tmp1[2], {4}, 0, len, radix)
	
	comp1 = MyCompareExp(s[1], s[2], tmp1[1], tmp1[2])
	comp2 = MyCompareExp(s[1], s[2], b[1], b[2])
	
	-- condition 1:
	if (not (comp1 = -1 and comp2 = 1)) and (not (comp2 = -1 and comp1 = 1)) then
		return 1
	end if
	
	sb = AddExp(s[1], s[2], Negate(b[1]), b[2], len, radix)
	sb[1] = AbsoluteValue(sb[1])
	
	if mflag = 1 then
		bc = AddExp(b[1], b[2], Negate(c[1]), c[2], len, radix)
		bc[1] = AbsoluteValue(bc[1])
		-- condition 2:
		tmp = DivideExp(bc[1], bc[2], {2}, 0, len, radix)
		comp1 = MyCompareExp(sb[1], sb[2], tmp[1], tmp[2])
		if comp1 >= 0 then
			return 1
		end if
		-- condition 4:
		comp1 = MyCompareExp(bc[1], bc[2], delta[1], delta[2])
		if comp1 = -1 then
			return 1
		end if
	else
		cd = AddExp(c[1], c[2], Negate(d[1]), d[2], len, radix)
		cd[1] = AbsoluteValue(cd[1])
		-- condition 3:
		tmp = DivideExp(cd[1], cd[2], {2}, 0, len, radix)
		comp1 = MyCompareExp(sb[1], sb[2], tmp[1], tmp[2])
		if comp1 >= 0 then
			return 1
		end if
		-- condition 5:
		comp1 = MyCompareExp(cd[1], cd[2], delta[1], delta[2])
		if comp1 = -1 then
			return 1
		end if
	end if
	return 0
end function

public function FindRootExp(integer rid, sequence n1, integer exp1, 
		sequence n2, integer exp2, PositiveScalar len, AtomRadix radix, integer littleEndian = 0)
	
	len += 3
	delta = {{1}, floor((exp1 + exp2) / 2) - (len) + 2}
	
	a = {n1, exp1}
	b = {n2, exp2}
	if littleEndian then
		fa = call_func(rid, {reverse(n1), exp1, len, radix})
		fa[1] = reverse(fa[1])
		fb = call_func(rid, {reverse(n2), exp2, len, radix})
		fb[1] = reverse(fb[1])
	else
		fa = call_func(rid, {n1, exp1, len, radix})
		fb = call_func(rid, {n2, exp2, len, radix})
	end if
	
	if fa[1][1] * fb[1][1] >= 0 then
		return 1 -- error
	end if
	
	comp1 = MyCompareExp(AbsoluteValue(fa[1]), fa[2], AbsoluteValue(fb[1]), fb[2])
	if comp1 = -1 then
		-- swap, and set c=a
		c = b
		b = a
		a = c
	else
		c = a
	end if
	fc = fa
	fs = {{1}, 0}
	mflag = 1
	lookatIter = 0
	
	while 1 do
		lookatIter += 1
		
		comp1 = MyCompareExp(fa[1], fa[2], fc[1], fc[2])
		comp2 = MyCompareExp(fb[1], fb[2], fc[1], fc[2])
		if comp1 != 0 and comp2 != 0 then
			-- calculate "s" (inverse quadratic interpolation)
			--s = (a*fb*fc) / ((fa-fb)*(fa-fc))
			tmp1 = AddExp(fa[1], fa[2], Negate(fb[1]), fb[2], len, radix)
			tmp2 = AddExp(fa[1], fa[2], Negate(fc[1]), fc[2], len, radix)
			tmp1 = MultiplyExp(tmp1[1], tmp1[2], tmp2[1], tmp2[2], len, radix)
			tmp2 = MultiplyExp(fb[1], fb[2], fc[1], fc[2], len, radix)
			tmp2 = MultiplyExp(tmp2[1], tmp2[2], a[1], a[2], len, radix)
			tmp1 = DivideExp(tmp2[1], tmp2[2], tmp1[1], tmp1[2], len, radix)
			s = tmp1
			
			--s += (b*fa*fc) / ((fb-fa)*(fb-fc))
			tmp1 = AddExp(fb[1], fb[2], Negate(fa[1]), fa[2], len, radix)
			tmp2 = AddExp(fb[1], fb[2], Negate(fc[1]), fc[2], len, radix)
			tmp1 = MultiplyExp(tmp1[1], tmp1[2], tmp2[1], tmp2[2], len, radix)
			tmp2 = MultiplyExp(fa[1], fa[2], fc[1], fc[2], len, radix)
			tmp2 = MultiplyExp(tmp2[1], tmp2[2], b[1], b[2], len, radix)
			tmp1 = DivideExp(tmp2[1], tmp2[2], tmp1[1], tmp1[2], len, radix)
			s = AddExp(s[1], s[2], tmp1[1], tmp1[2], len, radix)
			
			--s += (c*fa*fb) / ((fc-fa)*(fc-fb))
			tmp1 = AddExp(fc[1], fc[2], Negate(fa[1]), fa[2], len, radix)
			tmp2 = AddExp(fc[1], fc[2], Negate(fb[1]), fb[2], len, radix)
			tmp1 = MultiplyExp(tmp1[1], tmp1[2], tmp2[1], tmp2[2], len, radix)
			tmp2 = MultiplyExp(fa[1], fa[2], fb[1], fb[2], len, radix)
			tmp2 = MultiplyExp(tmp2[1], tmp2[2], c[1], c[2], len, radix)
			tmp1 = DivideExp(tmp2[1], tmp2[2], tmp1[1], tmp1[2], len, radix)
			s = AddExp(s[1], s[2], tmp1[1], tmp1[2], len, radix)
		else
			-- calculate "s" (secant rule)
			--s = b - (fb * (b-a)/(fb-fa))
			tmp1 = AddExp(b[1], b[2], Negate(a[1]), a[2], len, radix)
			tmp2 = AddExp(fb[1], fb[2], Negate(fa[1]), fa[2], len, radix)
			tmp1 = MultiplyExp(tmp1[1], tmp1[2], fb[1], fb[2], len, radix)
			tmp1 = DivideExp(tmp1[1], tmp1[2], tmp2[1], tmp2[2], len, radix)
			s = AddExp(b[1], b[2], Negate(tmp1[1]), tmp1[2], len, radix)
		end if
		
		if Condition1Thru_5(len, radix) then
			s = AddExp(a[1], a[2], b[1], b[2], len, radix)
			s = DivideExp(s[1], s[2], {2}, 0, len, radix)
			mflag = 1
		else
			mflag = 0
		end if
		
		if littleEndian then
			fs = call_func(rid, {reverse(s[1]), s[2], len, radix})
			fs[1] = reverse(fs[1])
		else
			fs = call_func(rid, {s[1], s[2], len, radix})
		end if
		
		d = c -- (d is assigned for the first time here, it won't be used above on the first iteration because mflag is set)
		c = b
		if fa[1][1] * fs[1][1] < 0 then
			b = s
		else
			a = s
		end if
		
		comp1 = MyCompareExp(AbsoluteValue(fa[1]), fa[2], AbsoluteValue(fb[1]), fb[2])
		if comp1 = -1 then
			-- swap(a, b)
			tmp = b
			b = a
			a = tmp
		end if
		
		tmp1 = AddExp(b[1], b[2], Negate(a[1]), a[2], len, radix)
		tmp1[1] = AbsoluteValue(tmp1[1])
		comp1 = MyCompareExp(tmp1[1], tmp1[2], delta[1], delta[2])
		if length(fb[1]) = 0 or length(fs[1]) = 0 or comp1 = -1 then
			exit
		end if
	end while
	
	len -= eurootsAdjustRound
	b = AdjustRound(b[1], b[2], len, radix)
	s = AdjustRound(s[1], s[2], len, radix)
	
	return {b, s, lookatIter}
end function

--mycomplex.e

-- Complex number functions

public constant REAL = 1, IMAG = 2

public type Complex(object x)
	if sequence(x) then
		if length(x) = 2 then
			if Eun(x[1]) then
				if Eun(x[2]) then
					return 1
				end if
			end if
		end if
	end if
	return 0
end type

public function NewComplex(Eun real = NewEun(), Eun imag = NewEun())
	return {real, imag}
end function

-- Negate the imaginary part of a Complex number
public function NegateImag(Complex a)
	a[IMAG][1] = Negate(a[IMAG][1])
	return a
end function

public function ComplexAdd(Complex a, Complex b)
	return {EunAdd(a[1], b[1]), EunAdd(a[2], b[2])}
end function

public function ComplexNegate(Complex b)
	return {EunNegate(b[1]), EunNegate(b[2])}
end function

public function ComplexSubtract(Complex a, Complex b)
	return {EunAdd(a[1], EunNegate(b[1])), EunAdd(a[2], EunNegate(b[2]))}
end function

public function ComplexMultiply(Complex n1, Complex n2)
	-- n1 = (a+bi)
	-- n2 = (c+di)
	-- (a+bi)(c+di) <=> ac + adi + bci + bdii
	-- <=> (ac - bd) + (ad + bc)i
	Eun real, imag
	real = EunSubtract(EunMultiply(n1[1], n2[1]), EunMultiply(n1[2], n2[2]))
	imag = EunAdd(EunMultiply(n1[1], n2[2]), EunMultiply(n1[2], n2[1]))
	return {real, imag}
end function

public function ComplexMultiplicativeInverse(Complex n2)
	-- Eun a, b, c
	-- (a+bi)(a-bi) <=> a*a + b*b
	-- n2 = (a+bi)
	-- a = n2[1]
	-- b = n2[2]
	-- c = (a*a + b*b)
	-- 1 / n2 <=> (a-bi) / (a*a + b*b)
	-- <=> (a / (a*a + b*b)) - (b / (a*a + b*b))i
	-- <=> (a / c) - (b / c)i
	Eun a, b, c, real, imag
	a = n2[1]
	b = n2[2]
	c = EunMultiplicativeInverse(EunAdd(EunMultiply(a, a), EunMultiply(b, b)))
	real = EunMultiply(a, c)
	imag = EunNegate(EunMultiply(b, c))
	return {real, imag}
end function

public function ComplexDivide(Complex n1, Complex n2)
	return ComplexMultiply(n1, ComplexMultiplicativeInverse(n2))
end function

public function ComplexSqrt(Complex a)
	--
	-- This equation takes REAL numbers as input to "x" and "y"
	-- So, they use the NON-complex functions to calculate them.
	-- sqrt(x + iy) <=> (1/2) * sqrt(2) * [ sqrt( sqrt(x*x + y*y) + x )  +  i*sign(y) * sqrt( sqrt(x*x + y*y) - x ) ]
	--
	-- NOTE: results are both positive and negative. Remember i (the imaginary part) is always both positive and negative in mathematics.
	-- NOTE: So, you will need to factor that information into your equations.
	Eun x, y, n1, n2, tmp, tmptwo
	Complex cret -- complex return value
	sequence s
	x = a[1]
	y = a[2]
	x[3] += 2
	y[3] += 2
	n1 = EunMultiply(x, x) -- a.real * a.real, x^2
	n2 = EunMultiply(y, y) -- a.imag * a.imag, y^2
	tmp = EunAdd(n1, n2) -- x^2 + y^2
	s = EunSqrt(tmp) -- should not return an imaginary number
	tmp = s[2] -- data member, get the postive answer
	n1 = EunAdd(tmp, x) -- a.real, (sqrt(x^2 + y^2) + x)
	n2 = EunSubtract(tmp, x) -- a.real, (sqrt(x^2 + y^2) - x), round down
	s = EunSqrt(n1) -- could check "isImaginaryFlag", but will always return real number
	if s[1] then
		puts(1, "Error(6):  In MyEuNumber, something went wrong in ComplexSqrt().\n  See file: ex.err\n")
		abort(1/0)
	end if
	n1 = s[2] -- sqrt(sqrt(x^2 + y^2) + x)
	s = EunSqrt(n2) -- could check "isImaginaryFlag", but will always return real number
	if s[1] then
		puts(1, "Error(6):  In MyEuNumber, something went wrong in ComplexSqrt().\n  See file: ex.err\n")
		abort(1/0)
	end if
	n2 = s[2] -- sqrt(sqrt(x^2 + y^2) - x)
	if length(y[1]) then -- a.imag
		if y[1][1] < 0 then
			n2[1] = Negate(n2[1])
		end if
	end if
	tmptwo = NewEun({2}, 0, x[3], x[4])
	s = EunSqrt(tmptwo)
	tmp = s[2]
	tmp = EunDivide(tmp, tmptwo)
	n1 = EunMultiply(n1, tmp)
	n2 = EunMultiply(n2, tmp)
	n1[3] -= 2 -- Do I need this here?
	n2[3] -= 2 -- Do I need this here?
	n1 = AdjustRound(n1[1], n1[2], n1[3], n1[4], noSubtractAdjust)
	n2 = AdjustRound(n2[1], n2[2], n2[3], n2[4], noSubtractAdjust)
	cret = NewComplex(n1, n2)
	return {cret, ComplexNegate(cret)}
end function

public function ComplexQuadraticEquation(Complex a, Complex b, Complex c)
	--done.
	-- About the Quadratic Equation:
	--
	-- The quadratic equation produces two answers (the answers may be the same)
	-- ax^2 + bx + c
	-- f(a,b,c) = (-b +-sqrt(b*b - 4*a*c)) / (2*a)
	-- answer[0] = ((-b + sqrt(b*b - 4*a*c)) / (2*a))
	-- answer[1] = ((-b - sqrt(b*b - 4*a*c)) / (2*a))
	--
	-- The "Complex" quadratic equation produces about 2 results
	--
	Complex ans, tmp
	sequence s
	ans = ComplexMultiply(a, c) -- a * c
	tmp = NewComplex(NewEun({4}, 0, a[1][3], a[1][4]), NewEun({}, 0, a[2][3], a[2][4])) -- 4
	ans = ComplexMultiply(tmp, ans) -- 4 * a * c
	tmp = ComplexMultiply(b, b) -- b * b
	ans = ComplexSubtract(tmp, ans) -- b * b - 4 * a * c
	s = ComplexSqrt(ans) -- sqrt(b * b - 4 * a * c)
	tmp = ComplexNegate(b)
	s[1] = ComplexAdd(s[1], tmp) -- (-b + sqrt(b * b - 4 * a * c))
	s[2] = ComplexAdd(s[2], tmp) -- s[2] is already negative
	ans = ComplexAdd(a, a) -- 2 * a
	ans = ComplexMultiplicativeInverse(ans) -- (1 / (2 * a))
	s[1] = ComplexMultiply(s[1], ans)
	s[2] = ComplexMultiply(s[2], ans)
	return s
end function

--quadraticEquation.e

-- The Quadratic Equation
-- 
-- ax^2 + bx + c = 0
-- 
-- x = (-b +-sqrt(b^2 - 4ac)) / (2a)
-- 
-- x1 = (-b + sqrt(b^2 - 4ac)) / (2a)
-- x2 = (-b - sqrt(b^2 - 4ac)) / (2a)
-- 
-- 4*a*c
-- Negate
-- b*b
-- Subtract
-- sqrt
-- b
-- Negate
-- Add/Subtract
-- 2a
-- divide
-- 
-- two answers

public function EunQuadraticEquation(Eun a, Eun b, Eun c)
	Eun n1, n2, n3, ans, tmp
	Complex c1, c2, c3
	sequence s
	if a[4] != b[4] or a[4] != c[4] then
		return 0
	end if
	if a[3] != b[3] or a[3] != c[3] then
		return 0
	end if
	ans = EunMultiply(a, c)
	ans = EunMultiply({{4}, 0, a[3], a[4]}, ans)
	ans = EunNegate(ans)
	tmp = EunMultiply(b, b)
	ans = EunAdd(tmp, ans)
	s = EunSqrt(ans)
	tmp = EunNegate(b)
	if s[1] then -- isImaginary, treat is as a Complex number
		-- Complex
		c1 = NewComplex(tmp, s[2]) -- (-b) + ans * i
		c2 = NewComplex(tmp, s[3]) -- (-b) - ans * i
		tmp = EunMultiply({{2}, 0, a[3], a[4]}, a)
		n3 = EunMultiplicativeInverse(tmp)
		c3 = NewComplex(n3, {{}, 0, a[3], a[4]})
		c1 = ComplexMultiply(c1, c3)
		c2 = ComplexMultiply(c2, c3)
		return {c1, c2}
	else
		n1 = EunAdd(tmp, s[2])
		n2 = EunAdd(tmp, s[3])
		tmp = EunMultiply({{2}, 0, a[3], a[4]}, a)
		tmp = EunMultiplicativeInverse(tmp)
		n1 = EunMultiply(n1, tmp)
		n2 = EunMultiply(n2, tmp)
		return {n1, n2}
	end if
end function

-- Additions:

public function ComplexCompare(Complex c1, Complex c2)
	integer ret
	ret = EunCompare(c1[REAL], c2[REAL])
	if ret then
		return ret
	end if
	ret = EunCompare(c1[IMAG], c2[IMAG])
	return ret
end function

public function ComplexAdjustRound(Complex c1, integer adjustBy = -1)
	return {EunAdjustRound(c1[1], adjustBy), EunAdjustRound(c1[2], adjustBy)}
end function


public function GetMoreAccuratePrec(Eun value1, PositiveScalar prec)
-- prec should be less than or equal to value1[3]
	return AdjustRound(value1[1], value1[2], prec + adjustRound, value1[4])
end function

public function EunGetPrec(Eun val)
	return val[3] - adjustRound
end function


-- Todo: Try to adjust the variables to give an accurate number.

public function EunTest(Eun val0, Eun ans)
	sequence val1, val2, range
	-- val0 = EunMultiplicativeInvserse(val)
	val1 = ans
	val1[3] = val0[3]
	val1 = EunAdjustRound(val1)
	range = Equaln(val0[1], val1[1])
	return range
end function



--end of file.
