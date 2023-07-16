-- Copyright (c) 2016-2023 James Cook

-- Class file for EuNumber

namespace prec

include classfile.e
include my.e

------------------------------------------
-- The beginning of the Table of Contents:
------------------------------------------

-- Class functions for Eun datatype:

--global function New(object x = {}) -- x can be a string, an atom, or an Eun
--global function NewId(integer id = 0)
--global procedure Free(integer id)
--global function Get(integer id, object index = {})
--global procedure Set(integer id, object x, object index = {})
--global procedure SetId(integer idDst, integer idSrc)

-- String functions:

--global function MySetString(integer id, object ob) -- ob can be a string or an atom
--global function MyGetString(integer id, Bool isDecimal = 0, integer padWithZeros = 0)

-- Default Options:

--global function GetZeroDividedByZero()
--global procedure SetZeroDividedByZero(Bool i)

--global procedure SetDefaultPrecision(integer prec, atom radix = 0, Bool isSetSpeed = 0, PositiveAtom speedDivBy = 3)
--global function GetDefaultPrecision()
--global function GetDefaultLimbRadix()
--global function GetDefaultLimbLength()
--global function GetDefaultSpeed()

--global procedure SetMaxIter(integer i)
--global function GetMaxIter()

-- Rounding:

--global procedure RoundAwayFromZero()
--global procedure RoundTowardsZero()
--global procedure RoundToPositiveInfinity()
--global procedure RoundToNegativeInfinity()

--global procedure SetRoundToZero(Bool i)
--global function GetRoundToZero()

-- Optional Integer Mode:

--global procedure SetIntegerMode(Bool i)
--global function GetIntegerMode()
--global procedure SetIntegerModeDecimals(integer i)
--global function GetIntegerModeDecimals()

--Other categories: (To be implimented later)
-- Random functions
-- Calculating status
-- Nanosleep

-- Eun "Id" functions:

-- Convert data functions, use with SetDefaultPrecision()

--global function GetVariables()
--global function NewVariables(object tableId, sequence s = {})
--global procedure MySetPrecision(integer id)
--global procedure MySetAllPrecision()

--global procedure MyRoundForAtomRadix(integer id, object correction = {})
--global procedure MyCompressLeadingDigit(integer id, object compressLead = {})
--global procedure MyUnCompressLeadingDigit(integer id)

-- Eun functions:

--global procedure MyEunAdjustRound(integer id, integer adjustBy = 0, integer isMixed = 1)
--global function MyEunMultiply(integer retid, integer id1, integer id2)
--global function MyEunSquared(integer retid, integer id1)
--global function MyEunAdd(integer retid, integer id1, integer id2)
--global function MyEunSum(integer retid, sequence dataIds)
--global procedure MyEunNegate(integer id1)
--global function MyEunAbsoluteValue(integer retid, integer id1)
--global function MyEunSubtract(integer retid, integer id1, integer id2)
--global function MyEunMultiplicativeInverse(integer retid, integer id1, sequence guess = {})
--global function MyEunDivide(integer retid, integer id1, integer id2)
--global function MyEunConvert(integer retid, integer id1, atom toRadix, TargetLength targetLength)
--global function MyEunRoundPrecision(integer retid, integer id1, integer prec = 0)
--global function MyEunCompare(integer id1, integer id2)
--global function MyGetEqualLength()
--global function MyGetCompareMin()
--global function MyEunIntPart(integer retid, integer id1)
--global function MyEunFracPart(integer retid, integer id1)
--global function MyEunRoundSignificantDigits(integer retid, integer id1, PositiveInteger sigDigits)
--global function MyEunCombInt(integer retid, integer id1, UpOneRange upOne = 0) -- upOne should be: 1, 0, or -1
--global function MyEunRoundToInt(integer retid, integer id1) -- Round to nearest integer

-- Remainder functions:

--global procedure MyEunModf(integer retid1, integer retid2, integer id1)
--global procedure MyEunfDiv(integer retid1, integer retid2, integer id1, integer id2)
--global function MyEunfMod(integer retid, integer id1, integer id2)

-- Additons:

--global function MyEunTest(integer id1, integer id2)

-- Matrix functions:

--global function MyNewMatrixStructure(integer rows, integer cols)
--global function MyGetMatrixRows(sequence a)
--global function MyGetMatrixCols(sequence a)
--global function GetAllValues(object s)
--global function SetAllValues(object s, object structure)
--global function MyMatrixMultiply(sequence a, sequence b)

-- MyEuNumber.e functions:

--global procedure MySetAdjustPrecision(PositiveInteger i)
--global function MyGetAdjustPrecision()
--global procedure MySetRealMode(Bool i)
--global function MyGetRealMode()
--global function MyEunNthRoot(integer retid, PositiveScalar n, integer id1, integer idguess = 0)
--global function MyEunSquareRoot(integer retid, integer id1, integer idguess = 0)
--global function MyEunCubeRoot(integer id1, integer idguess = 0)
--global function MyEunFourthRoot(integer id1, integer idguess = 0)

--global function MyGetE(integer retid)
--global function MyEunExp(integer retid, integer id1)
--global function MyEunExpFast(integer retid, integer id1, integer id2)
--global function MyEunLog(integer id1, integer idguess = 0)
--global function GetPrecision(integer id1)
--global function MyEunPower(integer retid, integer id1, integer id2, integer round = adjustPrecision)
--global function MyEunGeneralRoot(integer retid, integer id1, integer id2, integer round = adjustPrecision)

-- Trig functions (use radians)

--global function MyGetQuarterPI(integer retid, integer multBy = 1)
--global function MyGetHalfPI(integer retid)
--global function MyGetPI(integer retid)
--global function MyGetTwoPI(integer retid)

--global function MyEunDegreesToRadians(integer retid, integer id1)
--global function MyEunRadiansToDegrees(integer retid, integer id1)

--global function MyEunSin(integer retid, integer id1)
--global function MyEunCos(integer retid, integer id1)
--global function MyEunTan(integer retid, integer id1)
--global function MyEunArcTan(integer retid, integer id1)
--global function MyEunArcTan2(integer retid, integer id1, integer id2)
--global function MyEunArcSin(integer retid, integer id1)
--global function MyEunArcCos(integer retid, integer id1)

--global function MyEunCsc(integer retid, integer id1)
--global function MyEunSec(integer retid, integer id1)
--global function MyEunCot(integer retid, integer id1)
--global function MyEunArcCsc(integer retid, integer id1)
--global function MyEunArcSec(integer retid, integer id1)
--global function MyEunArcCot(integer retid, integer id1)

--global function MyEunSinh(integer retid, integer id1)
--global function MyEunCosh(integer retid, integer id1)
--global function MyEunTanh(integer retid, integer id1)
--global function MyEunCoth(integer retid, integer id1)
--global function MyEunSech(integer retid, integer id1)
--global function MyEunCsch(integer retid, integer id1)
--global function MyEunArcSinh(integer retid, integer id1)
--global function MyEunArcCosh(integer retid, integer id1)
--global function MyEunArcTanh(integer retid, integer id1)
--global function MyEunArcCoth(integer retid, integer id1)
--global function MyEunArcSech(integer retid, integer id1)
--global function MyEunArcCsch(integer retid, integer id1)

--global function EunTriangulation(integer id1, integer id2, integer id3, WhichOnes whichOnes = 3)

-- myeuroots.e

--global procedure MySetDelta(integer id1)
--global function MyGetDelta()
--global function MyGetLastDelta()
--global procedure MySetEurootsAdjustRound(PositiveInteger i)
--global function MyGetEurootsAdjustRound()
--global function MyEunFindRoot(integer funcId, integer id1, integer id2, integer littleEndian = 0, object passToFunc1 = {})

-- mycomplex.e

--global function GetValues(sequence s)
--global function SetValues(sequence s)
--global function GetComplex(sequence cids)
--global function SetComplex(Complex z)

--global function NewMyComplex(object real = {}, object imag = {})
--global function NewMyComplexFromIds(integer id1, integer id2)
--global function MyComplexRealPart(sequence cids)
--global function MyComplexImaginaryPart(sequence cids)
--global function MyComplexCompare(sequence cids1, sequence cids2)
--global function MyComplexAdjustRound(sequence cids1, integer adjustBy = 0)
--global function MyComplexAbsoluteValue(sequence cids) -- same as: ComplexModulus or ComplexMagnitude
--global function MyNegateImag(sequence a)
--global function MyComplexConjugate(sequence a)
--global function MyComplexAdd(sequence a, sequence b)
--global function MyComplexNegate(sequence b)
--global function MyComplexSubtract(sequence a, sequence b)
--global function MyComplexMultiply(sequence a, sequence b)
--global function MyComplexSquared(sequence z)
--global function MyComplexMultiplicativeInverse(sequence z)
--global function MyComplexDivide(sequence a, sequence b)

-- ComplexSquareRoot

--global procedure MySetComplexSquareRootAdjustRound(PositiveInteger i)
--global function MyGetComplexSquareRootAdjustRound()
--global function MyComplexSquareRootA(sequence z)
--global function MyComplexSquareRoot(sequence z)

-- ComplexExp and ComplexLog

--global function MyComplexExp(sequence z)
--global function MyComplexLog(sequence z)
--global function MyComplexPower(sequence z, sequence raisedTo)

-- Complex Trig Functions

--global function MyComplexCos(sequence z)
--global function MyComplexSin(sequence z)
--global function MyComplexTan(sequence z)

--global function MyComplexCosh(sequence z)
--global function MyComplexSinh(sequence z)

--global function MyComplexArcTanA(sequence z)
--global function MyComplexArcTan(sequence z)

--here, code more Complex Trig functions, see "wolfram alpha" on the Internet.

-- CompQuadraticEquation

--global function MyComplexQuadraticEquation(sequence a, sequence b, sequence c)
--global function MyEunQuadraticEquation(integer a, integer b, integer c)

--------------------------------
-- The end of Table of Contents.
--------------------------------

----------------------------------
-- Beginning of Library Functions:
----------------------------------

-- Class functions:

---------------
-- Constructor:
---------------

-- NOTE: This constructor does not use any Euphoria memory routines, only Euphoria objects.

global function New(object x = {}) -- x can be a string, an atom, or an Eun
    -- x can be an atom or a string
    integer id
    if not Eun(x) then
        x = ToEun(x) -- uses defaultRadix and defaultTargetLength (see: "SetDefaultPrecision()"), takes either an atom or a string.
    end if
    id = GetNewId(x)
    return id
end function

-- Use DOUBLE_INT_MAX (or an atom) in NewId() to get an uninitialized id.

global function NewId(atom id = 0)
    if id > 0 then
        if integer(id) then
            return NewObjectFromId(id)
        else
            return GetNewId() -- returns an uninitialized id.
        end if
    else
        return New(NewEun()) -- initializes it to an Eun with the value of zero (0).
            -- Defaults can be changed in SetDefaultPrecision().
            -- Then, use MySetPrecision() or MySetAllPrecision() on all ids.
    end if
end function

--------------
-- Destructor:
--------------

-- When a Euphoria program exits, it frees all data stored in Euphoria objects.
-- Other data, such as allocated memory, needs to be freed before the program exits.
-- In later versions of Euphoria, you can use delete_routine() for such data, see Euphoria documentation for "delete_routine()" and "delete()".

global procedure Free(integer id)
    -- Use Free() to save space.
    DeleteObject(id)
end procedure

----------
-- Access:
----------

-- Access any index value of an Eun_id, even the Eun value itself.

global function Get(integer id, object index = {})
    -- When should we round to precision ?
    -- Answer: On string output.
    return GetDataFromObject(id, index)
end function

----------
-- Assign:
----------

-- Assign any index value of an Eun_id, even the Eun value itself.

global procedure Set(integer id, object x, object index = {})
    ReplaceObject(id, x, index, 1, 0)
    if not Eun(GetDataFromObject(id)) then
        puts(1, "\nError in Set().\nThe program has encountered an error and must shutdown.")
        abort(1/0)
    end if
end procedure

-- Store an id to another id, giving them both the same value.

global procedure SetId(integer idDst, integer idSrc)
    StoreObject(idDst, idSrc)
end procedure

-----------------------------------------
-- String Functions for input and output:
-----------------------------------------

-- For User Input, use "New()" or "MySetString()":

global function MySetString(integer id, object ob) -- ob can be a string or an atom
    -- To set precision, use: SetDefaultPrecision().
    object x = ToEun(ob)
    Set(id, x)
    return id
end function

-- User Output (to string for use on screen):

global function MyGetString(integer id, Bool isDecimal = 0, integer padWithZeros = 0)
    object x = Get(id)
    integer prec
    if not ROUND_TO_NEAREST_OPTION then
        --if not prec then
        if length(x) >= 6 then
            prec = x[6]
        else
            prec = defaultPrecision
        end if
        --end if
        if prec > 0 then
            x = EunConvert(x, 2, prec)
        end if
    end if
    x = ToString(x, padWithZeros) -- ToString() can take an atom or an Eun
    if isDecimal then
        x = ToStringDecimal(x) -- ToStringDecimal() can take an atom, an Eun, or a character string returned from ToString().
    end if
    return x
end function

-------------------
-- Default Options:
-------------------

global function GetZeroDividedByZero()
    return zeroDividedByZero
end function

global procedure SetZeroDividedByZero(Bool i)
    zeroDividedByZero = i
end procedure

-- About Precision, base2 precision is:
-- Good for Eun_precision up to approximately 10^300000000 (for 32-bit Euphoria), using radix of 10,
-- or, floor(log(2)/log(radix) * maxInt) == maximum targetLength, for precision of base2
-- maximum Eun_precision == radix^(maximum targetLength)

integer defaultPrecision = 0 -- base2 precision

global procedure SetDefaultPrecision(integer prec, atom radix = 0, Bool isSetSpeed = 0, PositiveAtom speedDivBy = 3)
    defaultPrecision = prec
    if radix then
        SetDefaultRadix(radix)
    end if
    SetDefaultTargetLength( PrecisionToTargetLength(prec) )
    if isSetSpeed then
        SetCalcSpeed(floor(defaultTargetLength / speedDivBy))
    end if
end procedure

global function GetDefaultPrecision()
    -- Set in "SetDefaultPrecision()" function.
    return defaultPrecision
end function

global function GetDefaultLimbRadix()
    -- Set in "SetDefaultPrecision()" function.
    return GetDefaultRadix()
end function

global function GetDefaultLimbLength()
    -- Set in "SetDefaultPrecision()" function.
    return GetDefaultTargetLength()
end function

global function GetDefaultSpeed()
    -- Set in "SetDefaultPrecision()" function.
    -- returns an atom.
    return GetCalcSpeed()
end function

global procedure SetMaxIter(integer i)
    iter = i
end procedure

global function GetMaxIter()
    return iter
end function

-- Rounding mode:

global procedure RoundAwayFromZero()
    -- default rounding mode
    SetRound(ROUND_INF)
end procedure

global procedure RoundTowardsZero()
    SetRound(ROUND_ZERO)
end procedure

global procedure RoundToPositiveInfinity()
    SetRound(ROUND_POS_INF)
end procedure

global procedure RoundToNegativeInfinity()
    SetRound(ROUND_NEG_INF)
end procedure

-- Rounding infinitesimals:

global procedure SetRoundToZero(Bool i = TRUE)
    -- TRUE or FALSE.
    -- Round infinitesimals to zero, if true,
    -- else keep them, if false.
    isRoundToZero = i
end procedure

global function GetRoundToZero()
    return isRoundToZero
end function

-- Optional Integer Mode: (Round to Nearest digit)

global procedure SetIntegerMode(Bool i = TRUE)
    -- TRUE or FALSE.
    ROUND_TO_NEAREST_OPTION = i
end procedure

global function GetIntegerMode()
    return ROUND_TO_NEAREST_OPTION
end function

-- Sets or gets the number of decimal places after an IntegerMode floating point number:

global procedure SetIntegerModeDecimals(integer i = 0)
    -- Under IntegerMode, this sets the number of radix decimal places smaller than one (1).
    -- This works on all calculations.
    integerModeFloat = i
end procedure

global function GetIntegerModeDecimals()
    return integerModeFloat
end function



--Other categories:
-- Random functions
-- Calculating status
-- Nanosleep

-- Eun "Id" functions.  Use these "id" functions, defined above: New(), Free(), Get(), Set().

---------------------------
-- Set Precision functions:
---------------------------

global function GetVariables()
    return GetTableData()
end function

global function NewVariables(object tableId, sequence s = {})
    if table_t(s) then -- length(s) = 3 then
        s[TABLE] = tableId
    else
        s = NewTable(tableId)
    end if
    return SwapTable(s)
end function

global procedure MySetPrecision(integer id)
    -- Use on all ids, after SetDefaultPrecision(), using MySetAllPrecision()
    -- or, use on an individual id, using MySetPrecision().
    Eun a = Get(id)
    object x = EunConvert(a, defaultRadix, defaultTargetLength)
    x &= {0, defaultPrecision}
    Set(id, x)
end procedure

global procedure MySetAllPrecision()
    -- Converts all variables in the current table to defaults.
    -- Use after SetDefaultPrecision().
    for i = 1 to length(privateData) do
        if length(privateData[i]) then
            MySetPrecision(i)
        end if
    end for
end procedure

-------------------------------
-- End Set Precision functions.
-------------------------------

global procedure MyRoundForAtomRadix(integer id, object correction = {})
    Eun a = Get(id)
    object x
    if equal(correction, {}) then
        correction = 5 - floor(log(a[4]) / logTwo)
    end if
    x = RoundFloat(a[1], correction)
    Set(id, x, 1) -- set to first (1) index of Eun_id
end procedure

-- To save space with small numbers, use CompressLeadingDigit:
-- Not needed if you don't want to save space.
global procedure MyCompressLeadingDigit(integer id, object compressLead = {})
    Eun a = Get(id)
    object x
    if equal(compressLead, {}) then
        compressLead = floor(a[4] / 2)
    end if
    x = EunCompressLeadingDigit(a, compressLead)
    Set(id, x)
end procedure

global procedure MyUnCompressLeadingDigit(integer id)
    Eun a = Get(id)
    object x = EunUnCompressLeadingDigit(a)
    Set(id, x)
end procedure

-- MyEunAdjustRound:

global procedure MyEunAdjustRound(integer id, integer adjustBy = 0, ThreeOptions isMixed = 1)
    -- isMixed can be: 0, 1, or 2.
    -- 0, not mixed, use carry
    -- 1, mixed, use borrow and carry
    -- 2, no subtract adjust, use neither.
    -- adjustBy decreases number of limbs, rounding the Eun.
    Eun a = Get(id)
    object x = EunAdjustRound(a, adjustBy, isMixed)
    Set(id, x)
end procedure

-- Math functions:

global function MyEunMultiply(integer retid, integer id1, integer id2)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object x = EunMultiply(n1, n2)
    Set(retid, x)
    return retid
end function

global function MyEunSquared(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunSquared(n1)
    Set(retid, x)
    return retid
end function

global function MyEunAdd(integer retid, integer id1, integer id2)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object x = EunAdd(n1, n2)
    Set(retid, x)
    return retid
end function

global function MyEunSum(integer retid, sequence dataIds)
    object x = dataIds
    for i = 1 to length(dataIds) do
        x[i] = Get(x[i])
    end for
    x = EunSum(x)
    Set(retid, x)
    return retid
end function

global procedure MyEunNegate(integer id1)
    -- more portable to other programming languages this way:
    Eun n1 = Get(id1)
    object x = EunNegate(n1)
    Set(id1, x)
end procedure

global function MyEunAbsoluteValue(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunAbsoluteValue(n1)
    Set(retid, x)
    return retid
end function

global function MyEunSubtract(integer retid, integer id1, integer id2)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object x = EunSubtract(n1, n2)
    Set(retid, x)
    return retid
end function

global function MyEunMultiplicativeInverse(integer retid, integer id1, sequence guess = {})
    Eun n1 = Get(id1)
    object x = EunMultiplicativeInverse(n1, guess)
    Set(retid, x)
    return retid
end function

global function MyEunDivide(integer retid, integer id1, integer id2)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object x = EunDivide(n1, n2)
    Set(retid, x)
    return retid
end function

-- EunConvert:

global function MyEunConvert(integer retid, integer id1, atom toRadix, TargetLength targetLength)
    Eun n1 = Get(id1)
    object x = EunConvert(n1, toRadix, targetLength)
    Set(retid, x)
    return retid
end function

global function MyEunRoundPrecision(integer retid, integer id1, integer prec = 0)
    -- prec over-rides prec in Eun's and default-prec.
    Eun n1 = Get(id1)
    object x = EunRoundPrecision(n1, prec)
    Set(retid, x)
    return retid
end function

global function MyEunCompare(integer id1, integer id2)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    integer x = EunCompare(n1, n2)
    return x
end function

global function MyGetEqualLength()
    return GetEqualLength()
end function

global function MyGetCompareMin()
    return GetCompareMin()
end function

global function MyEunIntPart(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunIntPart(n1)
    Set(retid, x)
    return retid
end function

global function MyEunFracPart(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunFracPart(n1)
    Set(retid, x)
    return retid
end function

global function MyEunRoundSignificantDigits(integer retid, integer id1, PositiveInteger sigDigits)
    Eun n1 = Get(id1)
    object x = EunRoundSignificantDigits(n1, sigDigits)
    Set(retid, x)
    return retid
end function

global function MyEunCombInt(integer retid, integer id1, UpOneRange upOne = 0) -- upOne should be: 1, 0, or -1
-- if there is any fraction part, add or subtract one, away from zero,
-- or ceil, if upOne == 1, add one towards positive infinity, if "up = 1"
-- or floor, if upOne == -1, add one towards negative infinity, if "up = -1"
    Eun n1 = Get(id1)
    object x = EunCombInt(n1, 0, upOne)
    Set(retid, x)
    return retid
end function

global function MyEunRoundToInt(integer retid, integer id1) -- Round to nearest integer
    Eun n1 = Get(id1)
    object x = EunRoundToInt(n1)
    Set(retid, x)
    return retid
end function

-- Remainder functions:

global procedure MyEunModf(integer retid1, integer retid2, integer id1)
    Eun n1 = Get(id1)
    object x = EunModf(n1)
    Set(retid1, x[1])
    Set(retid2, x[2])
end procedure

global procedure MyEunfDiv(integer retid1, integer retid2, integer id1, integer id2)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object x = EunfDiv(n1, n2)
    Set(retid1, x[1])
    Set(retid2, x[2])
end procedure

global function MyEunfMod(integer retid, integer id1, integer id2)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object x = EunfMod(n1, n2)
    Set(retid, x)
    return retid
end function

-- Additions:

global function MyEunTest(integer id1, integer id2)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object range = EunTest(n1, n2)
    return range
end function

-- Matrix functions:

global function MyNewMatrixStructure(integer rows, integer cols)
    return repeat(repeat(0, cols), rows)
end function

global function MyGetMatrixRows(sequence a)
    return GetMatrixRows(a)
end function

global function MyGetMatrixCols(sequence a)
    return GetMatrixCols(a)
end function

global function GetAllValues(object s)
    if atom(s) then
        return Get(s)
    end if
    if length(s) then
        for i = 1 to length(s) do
            s[i] = GetAllValues(s[i])
        end for
    end if
    return s
end function

global function SetAllValues(object s, object structure)
    if atom(structure) then
        return New(s)
    end if
    if length(structure) then
        for i = 1 to length(structure) do
            s[i] = SetAllValues(s[i], structure[i])
        end for
    end if
    return s
end function

global function MyMatrixMultiply(sequence a, sequence b)
    object x = GetAllValues(a)
    object y = GetAllValues(b)
    object ret = MatrixMultiply(x, y)
    integer rows = GetMatrixRows(a)
    integer cols = GetMatrixCols(b)
    ret = SetAllValues(ret, MyNewMatrixStructure(rows, cols))
    return ret
end function

-- MyEuNumber.e functions:

global procedure MySetAdjustPrecision(PositiveInteger i)
    SetAdjustPrecision(i)
end procedure

global function MyGetAdjustPrecision()
    return GetAdjustPrecision()
end function

global procedure MySetRealMode(Bool i)
    SetRealMode(i)
end procedure

global function MyGetRealMode()
    return GetRealMode()
end function

-- Integer Roots:

global function MyEunNthRoot(PositiveScalar n, integer id1, integer idguess = 0)
    Eun n1 = Get(id1)
    object a = 0
    if idguess > 0 then
        a = Get(idguess)
    end if
    a = EunNthRoot(n, n1, a)
    if length(a) = 3 then
        a[2] = New(a[2])
        a[3] = New(a[3])
    else
        a = New(a)
    end if
    return a -- id, or, if sequence: {isImaginary, retPositiveId, retNegitiveId}
end function

global function MyEunSquareRoot(integer id1, integer idguess = 0)
    return MyEunNthRoot(2, id1, idguess)
end function

global function MyEunCubeRoot(integer id1, integer idguess = 0)
    return MyEunNthRoot(3, id1, idguess)
end function

global function MyEunFourthRoot(integer id1, integer idguess = 0)
    return MyEunNthRoot(4, id1, idguess)
end function

-- Exponentation and Logarithms:

global function MyGetE(integer retid)
    object x = GetE()
    Set(retid, x)
    return retid
end function

global function MyEunExp(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunExp(n1)
    Set(retid, x)
    return retid
end function

--global function MyEunExpFast(integer retid, integer id1, integer id2)
--    Eun n1 = Get(id1)
--    Eun n2 = Get(id2)
--    object x = EunExpFast(n1, n2)
--    Set(retid, x)
--    return retid
--end function

global function MyEunLog(integer id1) --, integer idguess = 0)
    Eun n1 = Get(id1)
    object a
    a = EunLog(n1)
    if length(a) = 2 then
        a[1] = New(a[1])
        a[2] = New(a[2])
    else
        a = New(a)
    end if
    return a
end function

-- Get precision:

global function GetPrecision(integer id1)
    Eun n1 = Get(id1)
    atom prec = GetPrecision(n1)
    return prec
end function

-- Powers: a number (base), raised to the power of another number (raisedTo)

global function MyEunPower(integer retid, integer id1, integer id2) --, integer round = adjustPrecision)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object x = EunPower(n1, n2) --, round)
    Set(retid, x)
    return retid
end function

-- Eun Roots: EunGeneralRoot()

global function MyEunGeneralRoot(integer retid, integer id1, integer id2) --, integer round = adjustPrecision)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object x = EunGeneralRoot(n1, n2) --, round)
    Set(retid, x)
    return retid
end function

-- NOTE: Remember to test "adjustPrecision" in myeunumber.e,
--       functions might need adjustments, to make it more accurate.


-- Trig Functions (use radians)

global function MyGetQuarterPI(integer retid, integer multBy = 1)
    object x = GetQuarterPI(defaultTargetLength, defaultRadix, multBy)
    Set(retid, x)
    return retid
end function

global function MyGetHalfPI(integer retid)
    return MyGetQuarterPI(retid, 2)
end function

global function MyGetPI(integer retid)
    return MyGetQuarterPI(retid, 4)
end function

global function MyGetTwoPI(integer retid)
    return MyGetQuarterPI(retid, 8)
end function

global function MyEunDegreesToRadians(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunDegreesToRadians(n1)
    Set(retid, x)
    return retid
end function

global function MyEunRadiansToDegrees(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunRadiansToDegrees(n1)
    Set(retid, x)
    return retid
end function

global function MyEunSin(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunSin(n1)
    Set(retid, x)
    return retid
end function

global function MyEunCos(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunCos(n1)
    Set(retid, x)
    return retid
end function

global function MyEunTan(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunTan(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcTan(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcTan(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcTan2(integer retid, integer id1, integer id2)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object x = EunArcTan2(n1, n2)
    Set(retid, x)
    return retid
end function

global function MyEunArcSin(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcSin(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcCos(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcCos(n1)
    Set(retid, x)
    return retid
end function

---Other trig functions:

global function MyEunCsc(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunCsc(n1)
    Set(retid, x)
    return retid
end function

global function MyEunSec(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunSec(n1)
    Set(retid, x)
    return retid
end function

global function MyEunCot(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunCot(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcCsc(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcCsc(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcSec(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcSec(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcCot(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcCot(n1)
    Set(retid, x)
    return retid
end function

-- Hyperbolic trig functions:

global function MyEunSinh(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunSinh(n1)
    Set(retid, x)
    return retid
end function

global function MyEunCosh(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunCosh(n1)
    Set(retid, x)
    return retid
end function

global function MyEunTanh(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunTanh(n1)
    Set(retid, x)
    return retid
end function

global function MyEunCoth(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunCoth(n1)
    Set(retid, x)
    return retid
end function

global function MyEunSech(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunSech(n1)
    Set(retid, x)
    return retid
end function

global function MyEunCsch(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunCsch(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcSinh(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcSinh(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcCosh(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcCosh(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcTanh(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcTanh(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcCoth(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcCoth(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcSech(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcSech(n1)
    Set(retid, x)
    return retid
end function

global function MyEunArcCsch(integer retid, integer id1)
    Eun n1 = Get(id1)
    object x = EunArcCsch(n1)
    Set(retid, x)
    return retid
end function

-- EunTriangulation

global function EunTriangulation(integer id1, integer id2, integer id3, WhichOnes whichOnes = 3)
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    Eun n3 = Get(id3)
    object a = EunTriangulation(n1, n2, n3, whichOnes)
    for i = 1 to length(a) do
        if sequence(a[i]) then
            a[i] = New(a[i])
        --else
        --    a[i] = 0
        end if
    end for
    return a -- a is one of: {retid1, retid2}, {0, retid2}, {retid1, 0}
end function

--myeuroots.e

global procedure MySetDelta(integer id1)
    Eun n1 = Get(id1)
    SetDelta(n1)
end procedure

global function MyGetDelta()
    return New(GetDelta())
end function

global function MyGetLastDelta()
    return New(GetLastDelta())
end function

global procedure MySetEurootsAdjustRound(PositiveInteger i)
    SetEurootsAdjustRound(i)
end procedure

global function MyGetEurootsAdjustRound()
    return GetEurootsAdjustRound()
end function

global function MyEunFindRoot(integer funcId, integer id1, integer id2, integer littleEndian = 0, object passToFunc1 = {})
    Eun n1 = Get(id1)
    Eun n2 = Get(id2)
    object a = EunFindRoot(funcId, n1, n2, littleEndian, passToFunc1)
    if length(a) then
        a[1] = New(a[1])
        a[2] = New(a[2])
    end if
    return a -- {} on error.
end function

--mycomplex.e

global function GetValues(sequence s)
    for i = 1 to length(s) do
        s[i] = Get(s[i])
    end for
    return s
end function

global function SetValues(sequence s)
    for i = 1 to length(s) do
        s[i] = New(s[i])
    end for
    return s
end function

-- GetComplex()

global function GetComplex(sequence cids)
    Complex r = GetValues(cids)
    return r
end function

-- SetComplex()

global function SetComplex(Complex z)
    sequence s = SetValues(z)
    return s
end function

-- NewMyComplex()

global function NewMyComplex(object real = {}, object imag = {})
    sequence s = {New(real), New(imag)}
    return s
end function

global function NewMyComplexFromIds(integer id1, integer id2)
    sequence s = {NewObjectFromId(id1), NewObjectFromId(id2)}
    return s
end function

global function MyComplexRealPart(sequence cids)
    return cids[REAL]
end function

global function MyComplexImaginaryPart(sequence cids)
    return cids[IMAG]
end function

global function MyComplexCompare(sequence cids1, sequence cids2)
    return ComplexCompare(GetComplex(cids1), GetComplex(cids2))
end function

global function MyComplexAdjustRound(sequence cids1, integer adjustBy = 0)
    object z = ComplexAdjustRound(GetComplex(cids1), adjustBy)
    z = SetComplex(z)
    return z
end function

global function MyComplexAbsoluteValue(sequence cids)
    -- same as: ComplexModulus or ComplexMagnitude
    -- Returns Real part
    object s = ComplexAbsoluteValue(GetComplex(cids))
    return New(s)
end function

-- Negate the imaginary part of a Complex number
global function MyNegateImag(sequence a)
    return SetComplex(NegateImag(GetComplex(a)))
end function

global function MyComplexConjugate(sequence a)
    return SetComplex(ComplexConjugate(GetComplex(a)))
end function

global function MyComplexAdd(sequence a, sequence b)
    return SetComplex(ComplexAdd(GetComplex(a), GetComplex(b)))
end function

global function MyComplexNegate(sequence b)
    return SetComplex(ComplexNegate(GetComplex(b)))
end function

global function MyComplexSubtract(sequence a, sequence b)
    return SetComplex(ComplexSubtract(GetComplex(a), GetComplex(b)))
end function

global function MyComplexMultiply(sequence a, sequence b)
    return SetComplex(ComplexMultiply(GetComplex(a), GetComplex(b)))
end function

global function MyComplexSquared(sequence z)
    return SetComplex(ComplexSquared(GetComplex(z)))
end function

global function MyComplexMultiplicativeInverse(sequence z)
    return SetComplex(ComplexMultiplicativeInverse(GetComplex(z)))
end function

global function MyComplexDivide(sequence a, sequence b)
    return SetComplex(ComplexDivide(GetComplex(a), GetComplex(b)))
end function

-- ComplexSquareRoot

global procedure MySetComplexSquareRootMoreAccuracy(PositiveInteger i)
    SetComplexSquareRootMoreAccuracy(i)
end procedure

global function MyGetComplexSquareRootMoreAccuracy()
    return GetComplexSquareRootMoreAccuracy()
end function

global function MyComplexSquareRootA(sequence z)
    object s = ComplexSquareRootA(GetComplex(z))
    s[1] = SetComplex(s[1])
    s[2] = SetComplex(s[2])
    return s
end function

global function MyComplexSquareRoot(sequence z)
    object s = ComplexSquareRoot(GetComplex(z))
    s[1] = SetComplex(s[1])
    s[2] = SetComplex(s[2])
    return s
end function

-- Additonal Complex Functions:

global function MyComplexExp(sequence z)
    return SetComplex(ComplexExp(GetComplex(z)))
end function

global function MyComplexLog(sequence z)
    return SetComplex(ComplexLog(GetComplex(z)))
end function

global function MyComplexPower(sequence z, sequence raisedTo)
    return SetComplex(ComplexPower(GetComplex(z), GetComplex(raisedTo)))
end function

-- Complex Trig Functions

global function MyComplexCos(sequence z)
    return SetComplex(ComplexCos(GetComplex(z)))
end function

global function MyComplexSin(sequence z)
    return SetComplex(ComplexSin(GetComplex(z)))
end function

global function MyComplexTan(sequence z)
    return SetComplex(ComplexTan(GetComplex(z)))
end function

global function MyComplexCosh(sequence z)
    return SetComplex(ComplexCosh(GetComplex(z)))
end function

global function MyComplexSinh(sequence z)
    return SetComplex(ComplexSinh(GetComplex(z)))
end function

global function MyComplexArcTanA(sequence z)
    return SetComplex(ComplexArcTanA(GetComplex(z)))
end function

global function MyComplexArcTan(sequence z)
    return SetComplex(ComplexArcTan(GetComplex(z)))
end function

-- ComplexQuadraticEquation

global function MyComplexQuadraticEquation(sequence a, sequence b, sequence c)
    object s = ComplexQuadraticEquation(GetComplex(a), GetComplex(b), GetComplex(c))
    s[1] = SetComplex(s[1])
    s[2] = SetComplex(s[2])
    return s
end function

-- EunQuadraticEquation

global function MyEunQuadraticEquation(integer a, integer b, integer c)
    object s = EunQuadraticEquation(Get(a), Get(b), Get(c))
    if Eun(s[1]) then
        s[1] = New(s[1])
        s[2] = New(s[2])
    else
        s[1] = SetComplex(s[1])
        s[2] = SetComplex(s[2])
    end if
    return s
end function

----------------------------
-- End of Library Functions.
----------------------------

--here

-- Work on error messages, later.
-- Work on E, PI, and Matrix functions, later.

