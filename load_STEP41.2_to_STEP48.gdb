set serial baud 230400
set tdesc filename armv6-core.xml 
set remote memory-read-packet-size 2048
set remote memory-write-packet-size 2048

target remote /dev/ttyUSB0
load

# disable breakpoint on non-existing symbol
set breakpoint pending off

# set breakpoint on Circle exit fonctions
break assertion_failed
break halt
break reboot


define HOOK_GDB_CALL_FUNCTION_AT_END_WHEN_STOPPED_BEFORE_PROLOG

        set $FUNCTION = (unsigned int)$arg0
        set $CALL_AT_END  = (unsigned int)$arg1
            
        # write return lr
        set *(unsigned int *)$CALL_AT_END =  $lr
        set $CALL_AT_END = $CALL_AT_END + 4
        set *(unsigned int *)$CALL_AT_END =  $FUNCTION
        set $CALL_AT_END = $CALL_AT_END + 12
        
        p/x $lr = $CALL_AT_END

        # CALL_AT_END
        set *(unsigned int *)$CALL_AT_END =  0xe50f0010
        set $CALL_AT_END = $CALL_AT_END + 4
        set *(unsigned int *)$CALL_AT_END =  0xe50f1010  
        set $CALL_AT_END = $CALL_AT_END + 4
        set *(unsigned int *)$CALL_AT_END =  0xe51f201c 
        set $CALL_AT_END = $CALL_AT_END + 4
        set *(unsigned int *)$CALL_AT_END =  0xe12fff32 
        set $CALL_AT_END = $CALL_AT_END + 4
        set *(unsigned int *)$CALL_AT_END =  0xe51f0020 
        set $CALL_AT_END = $CALL_AT_END + 4
        set *(unsigned int *)$CALL_AT_END =  0xe51f1020
        set $CALL_AT_END = $CALL_AT_END + 4
        set *(unsigned int *)$CALL_AT_END =  0xe51f2030
        set $CALL_AT_END = $CALL_AT_END + 4
        set *(unsigned int *)$CALL_AT_END =  0xe12fff12
        set $CALL_AT_END = $CALL_AT_END + 4
end 


define HOOK_GDB_REPLACE_FUNCTION_FAR
        set $SRC_ADDRESS  = (unsigned int)$arg0
        set $DEST_ADDRESS = (unsigned int)$arg1

        set *(unsigned int *)$SRC_ADDRESS = 0xe51ff004
        set $SRC_ADDRESS = $SRC_ADDRESS + 4
        set *(unsigned int *)$SRC_ADDRESS = $DEST_ADDRESS
end


set $Alpha_address      = 0x00300000
set $Alpha_exception    = $Alpha_address + 0x1200
set $Alpha_interrupt    = $Alpha_address + 0x1300
set $Alpha_serial_pin   = $Alpha_address + 0x1400
set $Alpha_serial_write = $Alpha_address + 0x1500


# Add execution to the Alpha memory space in MMU Page Table
tbreak CMemorySystem::EnableMMU()
command
        set m_pPageTable->m_pTable[ $Alpha_address / 0x100000 ] &= (~0x10)
        continue
end

# Recover Alpha exception after circle exception init
tbreak *CExceptionHandler::CExceptionHandler(void)
command
        HOOK_GDB_CALL_FUNCTION_AT_END_WHEN_STOPPED_BEFORE_PROLOG $Alpha_exception 0xF00
        continue
end


## Recall Alpha avec Circle Exception
tbreak *CInterruptSystem::Initialize(void)
command
        p/x $cpsr
        HOOK_GDB_CALL_FUNCTION_AT_END_WHEN_STOPPED_BEFORE_PROLOG $Alpha_interrupt 0xF00
     continue
end

tbreak *CSerialDevice::CSerialDevice(CInterruptSystem*, bool,unsigned int) 
command
       p/x $cpsr
      HOOK_GDB_CALL_FUNCTION_AT_END_WHEN_STOPPED_BEFORE_PROLOG $Alpha_serial_pin 0xF00
      continue
end


tbreak CSerialDevice::Write
command
 set $ADDR = $pc
 HOOK_GDB_REPLACE_FUNCTION_FAR $ADDR $Alpha_serial_write
 continue
end


# if this breakpoint is reached, the init of kernel is passed
break CKernel::Run()
