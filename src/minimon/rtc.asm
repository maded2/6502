                           ; Init VIA timers and IRQ for software real-time clock operation.
RTC_SETUP:                 ; This is normally only called in the boot-up routine.  You may
                           ; also want to reset time & date numbers if they don't make sense.
         LDA    #$4E       ; Set T1 to time out every 10ms @ 5MHz.  $C34E is 49,998 decimal.
         STA    VIA1T1CL   ;                                      T1 period = n+2 / φ2 freq
         LDA    #$C3
         STA    VIA1T1CH

         LDA    VIA1ACR    ; Set T1 to free-run and produce an interrupt every time-out.
         AND    #$7F
         ORA    #$40
         STA    VIA1ACR    ; Enable VIA1 to generate an interrupt every time T1 times out.

RTC_ON:  LDA    #$C0       ; Enable  T1 time-out interrupt.
         BRA    ro2
RTC_OFF: LDA    #$40       ; Disable T1 time-out interrupt.
 ro2:    STA    VIA1IER
         RTS
 ;------------------

cs_32     DFS   4    ; Reserve 4 bytes of RAM variable space for a 32-bit centisecond counter.
                     ; This record rolls over about every 471 days.  It is to ease calculation
                     ; of times and alarms that could cross irrelevant calendar boundaries.
                     ; Byte order is low byte first, high byte last.

CENTISEC  DFS   1    ; Now for the time-of-day (TOD) variables.
SECONDS   DFS   1    ; Reserve one byte of RAM variable space for each of these numbers.
MINUTES   DFS   1    ; At power-up, it's likely these numbers will make an invalid date
HRS       DFS   1    ; not just an incorrect date.  You might want to initialize them to
DAY       DFS   1    ; a date that at least makes sense, like midnight 1/1/04.
MO        DFS   1
YR        DFS   1


MO_DAYS_TBL: ; Number of days at which each month needs to roll over to the next month:
        DFB     32,  29,  32,  31,  32,  31,  32,  32,  31,  32,  31,  32
             ; Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
             ; (Feb will get special treatment.)

                                ; NMI vector points here.  Usually only 10 instructions
INCR10ms: PHA                   ; get executed.  Save A since we'll use it below.
          LDA   VIA1T1CL        ; Clear VIA1 interrupt.
          INC   cs_32           ; Increment the 4-byte variable cs_32.
          BNE   inc_TOD         ; If low byte didn't roll over, skip the rest.
          INC   cs_32+1         ; Else increment the next byte.
          BNE   inc_TOD         ; If that one didn't roll over, skip the rest.
          INC   cs_32+2         ; Etc..
          BNE   inc_TOD         ; (More than 99.6% of cases will skip out after
          INC   cs_32+3         ;  the first test.)

                        ; You could end it here if you don't need TOD and calendar.

 inc_TOD: INC   CENTISEC        ; Increment the hundredths of seconds in the 24-hour
          LDA   CENTISEC        ;                            clock/calendar section.
          CMP   #100            ; Compare cs to 100 (decimal, not hex).
          BMI   end_NMI         ; If not there yet, skip the rest of this
          STZ   CENTISEC        ; Otherwise zero it,
                                ; and go on to
          INC   SECONDS         ; increment the seconds.
          LDA   SECONDS
          CMP   #60             ; See if seconds carries to another minute.
          BMI   end_NMI         ; If not there yet, skip the rest of this.
          STZ   SECONDS         ; Otherwise zero it,
                                ; and go on to
          INC   MINUTES         ; increment the minutes.
          LDA   MINUTES
          CMP   #60             ; See if minutes carries to another hour.
          BMI   end_NMI         ; If not there yet, skip the rest of this.
          STZ   MINUTES         ; Otherwise zero it,
                                ; and go on to
          INC   HRS             ; increment the hours.
          LDA   HRS
          CMP   #24             ; See if hours carries to another day.
          BMI   end_NMI         ; If not there yet, skip the rest of this.
          STZ   HRS             ; Otherwise zero it,
                                ; and go on to
          INC   DAY             ; increment the day.

          LDA   MO              ; Now the irregular part.
          CMP   #2              ; Is it supposedly in February?
          BNE   notfeb          ; Branch if not.

          LDA   YR              ; For Feb, we have to see what year it is.
          AND   #11111100B      ; See if it's leap year by seeing
          CMP   YR              ; if it's a multiple of 4.
          BNE   notfeb          ; Branch if it's not;  ie, it's a 28-day Feb.

          LDA   DAY             ; Leap year Feb should only go to 29 days.
          CMP   #30             ; Did Feb just get to 30?
          BEQ   new_mo          ; If so, go increment month and re-init day to 1.
          PLA                   ; Otherwise restore the accumulator
          RTI                   ; and return to the regular program.

 notfeb:  PHX                   ; Save X for this indexing operation.
            LDX MO              ; Get the month as an index into
            LDA MO_DAYS_TBL-1,X ; the table of days for each month to increment,
          PLX                   ; and then restore X.
          CMP   DAY             ; See if we've reached that number of days
          BNE   end_NMI         ; If not, skip the rest of this.

 new_mo:  LDA   #1              ; Otherwise, it's a new month.  Put "1" in
          STA   DAY             ; the day of month again,
          INC   MO              ; and increment month.
          LDA   MO
          CMP   #13             ; See if it went to the 13th moth.
          BNE   end_NMI         ; If not, go to end.
          LDA   #1              ; Otherwise, reset the month to 1 (Jan),
          STA   MO

          INC   YR              ; and increment the year.
 end_NMI: PLA
          RTI
