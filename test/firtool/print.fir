; RUN: firtool %s --format=fir --ir-sv | FileCheck %s

circuit PrintTest:
  ; CHECK-LABEL: @PrintTest
  module PrintTest :
    input clock : Clock
    input cond : UInt<1>
    input var : UInt<32>
    printf(clock, cond, "test %d\n", var)

    ; CHECK:      sv.ifdef  @SYNTHESIS {
    ; CHECK-NEXT: } else {
    ; CHECK-NEXT:   sv.always posedge %clock {
    ; CHECK-NEXT:     [[PRINTF_COND:%.+]] = sv.macro.ref @PRINTF_COND_() : () -> i1
    ; CHECK-NEXT:     [[COND:%.+]] = comb.and bin [[PRINTF_COND]], %cond : i1
    ; CHECK-NEXT:     sv.if [[COND]] {
    ; CHECK-NEXT:       [[filename:%.+]] = sv.constantStr "fwrite.txt"
    ; CHECK-NEXT:       [[mode:%.+]] = sv.constantStr "a"
    ; CHECK-NEXT:       [[fd:%.+]] = sv.system "fopen"([[filename]], [[mode]]) : (!hw.string, !hw.string) -> i32
    ; CHECK-NEXT:       sv.fwrite [[fd]], "test %d\0A"(%var) : i32
    ; CHECK-NEXT:       sv.system "fclose"([[fd]]) : (i32) -> none
    ; CHECK-NEXT:     }
    ; CHECK-NEXT:   }
    ; CHECK-NEXT: }