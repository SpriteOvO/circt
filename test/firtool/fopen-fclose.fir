; RUN: firtool %s --format=fir --ir-sv | FileCheck %s

FIRRTL version 4.0.0
circuit FOpenFCloseTest:
  ; CHECK-LABEL: @FOpenFCloseTest
  public module FOpenFCloseTest :
    input clock : Clock
    input cond : UInt<1>
    input var : UInt<32>
    node fd = intrinsic(circt_fopen<filename = "file.txt", mode = "a"> : SInt<32>)
    printf(clock, cond, "test %d\n", var)
    intrinsic(circt_fclose, fd)

    ; CHECK:      [[filename:%.+]] = sv.constantStr "file.txt"
    ; CHECK-NEXT: [[mode:%.+]] = sv.constantStr "a"
    ; CHECK-NEXT: [[fd:%.+]] = sv.system "fopen"([[filename]], [[mode]]) {sv.namehint = "fd"} : (!hw.string, !hw.string) -> i32
    ; CHECK-NEXT: sv.ifdef  @SYNTHESIS {
    ; CHECK-NEXT: } else {
    ; CHECK-NEXT:   sv.always posedge %clock {
    ; CHECK-NEXT:     [[PRINTF_COND:%.+]] = sv.macro.ref @PRINTF_COND_() : () -> i1
    ; CHECK-NEXT:     [[COND:%.+]] = comb.and bin [[PRINTF_COND]], %cond : i1
    ; CHECK-NEXT:     sv.if [[COND]] {
    ; CHECK-NEXT:       [[filename2:%.+]] = sv.constantStr "fwrite.txt"
    ; CHECK-NEXT:       [[fd2:%.+]] = sv.system "fopen"([[filename2]], [[mode]]) : (!hw.string, !hw.string) -> i32
    ; CHECK-NEXT:       sv.fwrite [[fd2]], "test %d\0A"(%var) : i32
    ; CHECK-NEXT:       sv.system "fclose"([[fd2]]) : (i32) -> none
    ; CHECK-NEXT:     }
    ; CHECK-NEXT:   }
    ; CHECK-NEXT: }
    ; CHECK-NEXT: sv.system "fclose"([[fd]]) : (i32) -> none