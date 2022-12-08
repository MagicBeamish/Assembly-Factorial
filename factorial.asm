.data  
    header: .asciiz "Input an integer: "

.text
main:
    li $v0, 4               #Give the header to the user
    la $a0, header
    syscall

    li $v0, 5               #Take the input from the console
    syscall

    addi $t0, $v0, 0        #Move the input to temporary register $t0

    jal factorial           #Jump and link to the factorial function

    li $v0, 1               #Print the resulting number from the factorial function to the console
    move $a0, $t1
    syscall

    li $v0, 10              #End of program
    syscall

.end main

.text
factorial:                  #Beginning of the main factorial function

    addi $sp, $sp, -8       #Create enough room on the stack for the input and return values of the function by moving the stack pointer 
    sw $ra, 0($sp)          #The return address will be saved to 0 bytes on the stack pointer
    sw $s0, 4($sp)          #The input address will be saved to 4 bytes on the stack pointer

    add $s0, $t0, $zero     #Copy the $t0 value to $s0. It will be stored to the stack each step in the recursion.

    bne $t0, $zero, else    #If the number is not equal to 0 then jump to else.
                            #Every time else will subtract 1 from the original value and create a new link address.

    addi $t1, $zero, 1      #If $t0 is 0 then add 1 to $t1 which will be returned

    jal finish              #Jump and link to finish. This will only occur once $t0 has reached 0. By jumping
                            #and linking to finish. This concludes the first half of the program where factorial
                            #is called recursively.

else: 
    addi $t0, $t0, -1       #Subtract 1 from the latest value

    jal factorial           #The address of this jump and link will be stored to the stack pointer in 'factorial'
                            #When $t0 reaches zero, and therefor 'finish', the program will load this address alongside
                            #the next most recent value of $s0.

    mul $t1, $t1, $s0       #Each time 'finish' executes "lw $ra, 0($sp)" this is the step that will load,
                            #when that happens the program will execute this step.

finish:
    lw $ra, 0($sp)          #Load the bytes stored in the stack to the return address, returning to "mul $t1, $t1, $s0"
    lw $s0, 4($sp)          #Load the next most recent value of $t0 after it reached 0. 1, 2, 3...
    addi $sp, $sp, 8        #Move the stack pointer up 8 bytes to the location of the next return address
    jr $ra                  #Jump back to the next step after "jal factorial" in the main program