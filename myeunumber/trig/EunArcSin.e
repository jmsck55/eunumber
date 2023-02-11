-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/AddExp.e
include ../../eunumber/minieun/Multiply.e
include ../../eunumber/eun/EunDivide.e
include ../../eunumber/eun/EunNegate.e

include ../myeun/EunSquareRoot.e

include EunArcTan.e
include GetPI.e


--NOTE: ***Not using ArcSinExp() for now.  Instead, use ArcTanExp() and related identity functions.***
--
-- --                  1*z^3     1*3*z^5     1*3*5*z^7
-- -- arcsin(z) = z + (-----) + (-------) + (---------) + ...
-- --                   2* 3      2*4* 5      2*4*6* 7
--
-- -- Pattern: (1,2,3) ; (1,2,3,4,5) ; (1,2,3,4,5,6,7) ; (1,2,3,4,5,6,7,8,9)
-- -- odds on top, evens on bottom, except for the latest odd value.
--
-- --Note: Too slow?
--
-- global PositiveOption arcSinMoreAccuracy = -1 -- if -1, then use calculationSpeed
--
-- global procedure SetArcSinMoreAccuracy(PositiveOption i)
--      arcSinMoreAccuracy = i
-- end procedure
-- global function GetArcSinMoreAccuracy()
--      return arcSinMoreAccuracy
-- end function
--
-- global integer arcSinIter = 1000000000
-- global integer arcSinIterCount = 0
--
-- global sequence arcSinHowComplete = {1, 0}
--
-- global function GetArcSinHowCompleteMin()
--      return arcSinHowComplete[1]
-- end function
--
-- global function GetArcSinHowCompleteMax()
--      return arcSinHowComplete[2]
-- end function
--
-- global function ArcSinExp(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix)
-- --something wrong with arcsin()?
--
-- -- working on Trig functions
--
-- -- arcsin(z) = z + (1/2)(z^3/3) + (1*3/(2*4))(z^5/5) + (1*3*5/(2*4*6))(z^7/7) + ...
--      sequence sum, xSquared, top, bottom, odd, even, x, tmp, lookat, ret
--      integer protoTargetLength, moreAccuracy
--      arcSinHowComplete = {1, 0}
--      if arcSinMoreAccuracy >= 0 then
--              moreAccuracy = arcSinMoreAccuracy
--      elsif calculationSpeed then
--              moreAccuracy = Ceil(targetLength / calculationSpeed)
--      else
--              moreAccuracy = 0 -- changed to 0
--      end if
--      -- targetLength += adjustPrecision
--      protoTargetLength = targetLength + moreAccuracy + 1
--      -- sum = {n1, exp1}
--      x = {n1, exp1}
--      xSquared = SquaredExp(n1, exp1, targetLength, radix)
--      bottom = {{2}, 0}
--      odd = {{3}, 0}
--      -- First iteration:
--      tmp = MultiplyExp(bottom[1], bottom[2], odd[1], odd[2], targetLength, radix)
--      x = MultiplyExp(x[1], x[2], xSquared[1], xSquared[2], targetLength, radix)
--      tmp = DivideExp(x[1], x[2], tmp[1], tmp[2], targetLength, radix)
--      sum = AddExp(sum[1], sum[2], tmp[1], tmp[2], targetLength, radix)
--      -- Second iteration(s):
--      top = {{1}, 0}
--      even = {{2}, 0}
--      ret = sum
--      arcSinIterCount = arcSinIter
--      for n = 1 to arcSinIter do
--              even = AddExp(even[1], even[2], {2}, 0, protoTargetLength, radix)
--              bottom = MultiplyExp(bottom[1], bottom[2], even[1], even[2], protoTargetLength, radix)
--              top  = MultiplyExp(top[1], top[2], odd[1], odd[2], protoTargetLength, radix)
--              odd = AddExp(odd[1], odd[2], {2}, 0, protoTargetLength, radix)
--              tmp = MultiplyExp(bottom[1], bottom[2], odd[1], odd[2], protoTargetLength, radix)
--              x = MultiplyExp(x[1], x[2], xSquared[1], xSquared[2], protoTargetLength, radix)
--              tmp = DivideExp(x[1], x[2], tmp[1], tmp[2], protoTargetLength, radix)
--              tmp = MultiplyExp(tmp[1], tmp[2], top[1], top[2], protoTargetLength, radix)
--              sum = AddExp(sum[1], sum[2], tmp[1], tmp[2], protoTargetLength, radix)
--              lookat = ret
--              ret = AdjustRound(sum[1], sum[2], targetLength, radix, NO_SUBTRACT_ADJUST)
--              if ret[2] = lookat[2] then
--                      arcSinHowComplete = Equaln(ret[1], lookat[1])
--                      if arcSinHowComplete[1] = arcSinHowComplete[2] then
--                      -- if equal(ret[1], lookat[1]) then
--                              arcSinIterCount = n
--                              exit
--                      end if
--              end if
-- ifdef not NO_SLEEP_OPTION then
--              sleep(nanoSleep)
-- end ifdef
--      end for
--      if arcSinIterCount = arcSinIter then
--              call_proc(divideCallBackId, {3})
--              return {}
--      end if
--      -- targetLength -= adjustPrecision
--      ret = AdjustRound(ret[1], ret[2], targetLength, radix, NO_SUBTRACT_ADJUST)
--      return ret
-- end function

-- arcsin(x) = arctan( x / sqrt(1 - x^2) )
-- arccos(x) = arctan( sqrt(1 - x^2) / x )

global function EunArcSin(Eun a)
-- arcsin(x) = arctan( x / sqrt(1 - x^2) )
    object ob1
    if length(a[1]) = 1 and (a[1][1] = 1 or a[1][1] = -1) then
        ob1 = GetHalfPI(a[3], a[4])
        if a[1][1] = -1 then
            ob1 = EunNegate(ob1)
        end if
        return ob1
    end if
    ob1 = SquaredExp(a[1], a[2], a[3], a[4])
    ob1 = SubtractExp({1}, 0, ob1[1], ob1[2], a[3], a[4])
    ob1 = EunSquareRoot(ob1)
    if ob1[1] then
        puts(2, "Error: -- Trig error.\n")
        abort(1/0)
    end if
    ob1 = EunDivide(a, ob1[2])
    ob1 = EunArcTan(ob1)
    return ob1
    --return ArcSinExp(a[1], a[2], a[3], a[4])
end function
