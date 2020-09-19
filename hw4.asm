
#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################

.text

# Part I
init_game:
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    
    move $s0, $a0			#save a0 in s0
    move $s1, $a1			#save a1 in s1
   # move $t1, $a1
    move $s2, $a2			#save a2 in s2

    li $v0, 13				#Open up the file
    move $a0, $s0
    li $a1, 0
    li $a2, 0
    syscall
    blt $v0, 0, return_error
    move $s3, $v0			#save v0 in s3
    
    
    addi $sp, $sp, -3
    li $v0, 14				#Read the row number
    move $a0, $s3
    move $a1, $sp
    li $a2, 3
    syscall
   
   
    li $t3, 0
    li $t4, 10
    convertRowNumLoop: 			#Convert row number from char to int
        lbu $t0, ($sp)
        beq $t0, 10, found_rowNum
        addi $t2, $t0, -48
        mul $t3, $t3, $t4
        add $t3, $t3, $t2
        addi $sp, $sp, 1
        j convertRowNumLoop
    found_rowNum:
        addi $sp, $sp, 1
        sb $t3, ($s1)
        addi $s1, $s1, 1
        
        addi $sp, $sp, -3
        li $v0, 14			#Read the col number
        move $a0, $s3
        move $a1, $sp
        li $a2, 3
        syscall
        
    li $t5, 0
    convertColNumLoop:
        lbu $t0, ($sp)
        beq $t0, 10, found_colNum
        addi $t2, $t0, -48
        mul $t5, $t5, $t4
        add $t5, $t5, $t2
        addi $sp, $sp, 1
        j convertColNumLoop
    
    found_colNum:
    	addi $sp, $sp, 1
    	sb $t5, ($s1)
    	addi $s1, $s1, 1		#move s1 to byte 2
    
    
    mul $t0, $t3, $t5		#t0 = total # of elements
    li $t2, 0			#Counter
    li $t6, 0			#Counter for row
    li $t7, 0			#Counter for coln
    setGameLoop:
    ################SETTING UP THE GAME MAP##################
        beq $t2, $t0, fin_gameSet
        addi $sp, $sp, -1
        li $v0, 14
        move $a0, $s3
        move $a1, $sp
        li $a2, 1
        syscall
        
        lbu $t4, ($sp)
        beq $t4, 10, ignore_newLine
        
        
        beq $t4, 64, player_position
	xori $t4, $t4, 0x80			#Set the hidden flag
	
        j write_to_map
        
        player_position:
            xori $t4, $t4, 0x80			#Set the hidden flag
        #STORE ROW AND COL POSITION OF PLAYER TO PLAYER POINTER
            sb $t6, ($s2)
            addi $s2, $s2, 1
            sb $t7, ($s2)
            addi $s2, $s2, 1
        
        write_to_map:
            sb $t4, ($s1)
            addi $s1, $s1, 1
        
            addi $sp, $sp, 1
            addi $t2, $t2, 1		#Update counter
            addi $t7, $t7, 1		#Coln # ++
            beq $t7, $t5, updateRowCounter
            j setGameLoop
        
        updateRowCounter:
            addi $t6, $t6, 1		#Row # ++
            li $t7, 0			#Set coln to 0 again
            j setGameLoop
        
        ignore_newLine:
            addi $sp, $sp, 1
            j setGameLoop
            
    fin_gameSet:
        addi $sp, $sp, -1		#Ignore the new line after the map cell
        li $v0, 14
        move $a0, $s3
        move $a1, $sp
        li $a2, 1
        syscall
        addi $sp, $sp, 1
        
        addi $sp, $sp, -3
        li $v0, 14
        move $a0, $s3
        move $a1, $sp
        li $a2, 3
        syscall
        
    li $t0, 0
    li $t2, 10
    li $t3, 0
    li $t4, 0
    player_healthLoop:
        lb $t1, ($sp)			#load player's health (signed)
        beq $t1, 10, gotHealth
        
        addi $t1, $t1, -48
        mul $t3, $t3, $t2		# times 10
        add $t3, $t3, $t1
        
        addi $sp, $sp, 1
        j player_healthLoop
        
    gotHealth:
       addi $sp, $sp, 1
       sb $t3, ($s2)
       addi $s2, $s2, 1
       sb $t4, ($s2)
       
       li $v0, 16
       move $a0, $s3
       syscall

    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    addi $sp, $sp, 16
    
    li $v0, 0
    jr $ra
    
    return_error:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        addi $sp, $sp, 16

        li $v0, -1
        jr $ra

# Part II
is_valid_cell:
    bltz $a1, error			#if row < 0, error
    lbu $t0, ($a0)			
    bge $a1, $t0, error                 #if row >= map.row, error
    
    bltz $a2, error			#if col < 0, error
    addi $a0,$a0,1
    lbu $t0,($a0)
    bge $a2, $t0, error			#if col >= map.col, error
    
    li $v0,0
    jr $ra
    
    error:
        li $v0,-1
        jr $ra

# Part III
get_cell:
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)
    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    
    jal is_valid_cell
    beq $v0, -1, unableToGet
    
    addi $s0, $s0, 1			#move pointer to col #
    lbu $t0, ($s0)
    mul $t1, $s1, $t0			#t1 = i*C
    add $t1, $t1, $s2			#t1 = i*C +j
    addi $s0, $s0, 1			#addr of map cells
    add $t1, $t1, $s0			#t1 = addr(i*C+j)
    lbu $v0, ($t1)
    
    
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra
    
    unableToGet:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $ra, 12($sp)
        addi $sp, $sp, 16
        
        li $v0, -1
        jr $ra

# Part IV
set_cell:
    addi $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)
    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    
    jal is_valid_cell
    beq $v0, -1, UnableToSet
    
    addi $s0, $s0, 1			#move map pointer to col#
    lbu $t0, ($s0)
    mul $t1, $t0, $s1			#t1 = i*C
    add $t1, $t1, $s2			#t1 = i*C+j
    addi $s0, $s0, 1			#addr of map cells
    add $t1, $t1, $s0			#addr of (i*C+j)
    sb $s3, ($t1)
    
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
        
    li $v0, 0
    jr $ra
        
    UnableToSet:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $ra, 16($sp)
        addi $sp, $sp, 20
        
        li $v0, -1
        jr $ra


# Part V
reveal_area:
    addi $sp, $sp, -36
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)
    sw $ra, 32($sp)
    
    move $s0, $a0		#s0 = map_ptr
    move $s1, $a1		#s1 = row
    move $s2, $a2		#s2 = col
    
    addi $s3, $a1, -1		#s3 = row - 1		(i)
    addi $s4, $a2, -1		#s4 = col - 1		(j)
    move $s7, $s4		#s7 = copy of s4
    
    li $s6, 0			#row counter = 0
    row_loop:
        beq $s6, 3, exit_row_loop
        li $s5, 0			#col counter = 0
        col_loop:
            beq $s5, 3, exit_col_loop
            move $a0, $s0
            move $a1, $s3			#get(row - 1, col - 1)
            move $a2, $s4
            jal is_valid_cell
            beq $v0, -1, invalid_cell
            move $a0, $s0
            move $a1, $s3
            move $a2, $s4
            jal get_cell
            andi $t0, $v0, 0x80
            beq $t0, 0x80, revealCell
            
            addi $s4, $s4, 1
            addi $s5, $s5, 1
            j col_loop
        
        revealCell:
            xori $v0, $v0, 0x80
            move $a0, $s0
            move $a1, $s3
            move $a2, $s4
            move $a3, $v0
            jal set_cell
            
            addi $s4, $s4, 1		#move to next col
            addi $s5, $s5, 1
            j col_loop
        
        invalid_cell:		
            addi $s4, $s4, 1		#move to next col
            addi $s5, $s5, 1		#col counter ++
            j col_loop
        
   
        exit_col_loop:
            addi $s3, $s3, 1		#move to next row
            addi $s6, $s6, 1		#row counter++
            move $s4, $s7		#reset col#
            j row_loop
         
    exit_row_loop:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $s5, 20($sp)
        lw $s6, 24($sp)
        lw $s7, 28($sp)
        lw $ra, 32($sp)
    
        addi $sp, $sp, 36
        jr $ra

# Part VI
get_attack_target:
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $ra, 20($sp)
    
    move $s0, $a0		#s0 = map_ptr
    move $s1, $a1		#s1 = player_ptr
    move $s2, $a2		#s2 = direction (MUST BE U,D,L,or R)
    
    lbu $s3, ($a1)		#s3 = row of player
    addi $a1, $a1, 1
    lbu $s4, ($a1)		#s4 = col of player
    
    beq $a2, 'U', get_up
    beq $a2, 'D', get_down
    beq $a2, 'L', get_left
    beq $a2, 'R', get_right
    j wrong_instruction         #If none of instructions, error,
    
    get_up:					#(player.row-1, player.col)
        move $a0, $s0
        addi $t0, $s3, -1		
        move $a1, $t0
        move $a2, $s4
        jal get_cell
        j check_get_cell
        
    get_down:					#(player.row+1, player.col)
        move $a0, $s0
        addi $t0, $s3, 1
        move $a1, $t0
        move $a2, $s4
        jal get_cell
        j check_get_cell
        
    get_left:					#(player.row, player.col-1)
        move $a0, $s0
        move $a1, $s3
        addi $t0, $s4, -1
        move $a2, $t0
        jal get_cell
        j check_get_cell
        
    get_right:					#(player.row, player.col+1)
        move $a0, $s0
        move $a1, $s3
        addi $t0, $s4, 1
        move $a2, $t0
        jal get_cell
        j check_get_cell
    
    check_get_cell:
        beq $v0, -1, wrong_instruction
        beq $v0, 'm', return_monster
        beq $v0, 'B', return_boss
        beq $v0, '/', return_door
        j wrong_instruction
        
    return_monster:
        li $v0, 'm'
        j success_return
    return_boss:
        li $v0, 'B'
        j success_return
    return_door:
        li $v0, '/'
        j success_return
    
    success_return:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $ra, 20($sp)
        addi $sp, $sp, 24
        
        jr $ra
    
    wrong_instruction:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $ra, 20($sp)
        addi $sp, $sp, 24
        
        li $v0, -1
        jr $ra


# Part VII
complete_attack:
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $ra, 20($sp)
    
    move $s0, $a0		#s0 = map_ptr
    move $s1, $a1		#s1 = player_ptr
    move $s2, $a2		#s2 = target_row
    move $s3, $a3		#s3 = target_col
    
    addi $a1, $a1, 2		#move player_ptr to health
    lb $s4, ($a1)		#s4 = player's health
    
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    jal get_cell
    beq $v0, 'm', attack_monster
    beq $v0, 'B', attack_boss
    beq $v0, '/', attack_door
   
    attack_monster:
        move $a0, $s0
        move $a1, $s2
        move $a2, $s3
        li $a3, '$'
        jal set_cell
        addi $s4, $s4, -1
        move $t0, $s1
        addi $t0, $t0, 2
        sb $s4, ($t0)
        j check_health
        
    attack_boss:
        move $a0, $s0
        move $a1, $s2
        move $a2, $s3
        li $a3, '*'
        jal set_cell
        addi $s4, $s4, -2
        move $t0, $s1
        addi $t0, $t0, 2
        sb $s4, ($t0)
        j check_health
        
    attack_door:
        move $a0, $s0
        move $a1, $s2
        move $a2, $s3
        li $a3, '.'
        jal set_cell
        j fin_attack
        
    check_health:
       blez $s4, player_died
       j fin_attack
       
    player_died:
        lbu $t1, ($s1)			#t1 = player.row
        addi $s1, $s1, 1
        lbu $t2, ($s1)			#t2 = player.col
        move $a0, $s0
        move $a1, $t1
        move $a2, $t2
        li $a3, 'X'
        jal set_cell
        
        j fin_attack
    fin_attack:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $ra, 20($sp)
        addi $sp, $sp, 24
        jr $ra


# Part VIII
monster_attacks:
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $ra, 20($sp)
    
    move $s0, $a0			#s0 = map_ptr
    move $s1, $a1			#s1 = player_ptr
    lbu $s2, ($a1)			#s2 = player.row
    addi $a1, $a1, 1
    lbu $s3, ($a1)			#s3 = player.col
    
    li $s4, 0				#s4 = counter of monster damage
    
   #Check Up Char	(player.row-1, player.col)
        move $a0, $s0
        move $t0, $s2
        addi $t0, $t0, -1
        move $a1, $t0
        move $a2, $s3
        jal get_cell
        beq $v0, 'm', found_monster_up
        beq $v0, 'B', found_boss_up
        j check_down
        
    found_monster_up:
        addi $s4, $s4, 1
        j check_down
    found_boss_up:
        addi $s4, $s4, 2
        j check_down    
        
    #Check Down Char	(player.row+1, player.col)
    check_down:
        move $a0, $s0
        move $t0, $s2
        addi $t0, $t0, 1
        move $a1, $t0
        move $a2, $s3
        jal get_cell
        beq $v0, 'm', found_monster_down
        beq $v0, 'B', found_boss_down
        j check_left
    found_monster_down:
        addi $s4, $s4, 1
        j check_left
    found_boss_down:
        addi $s4, $s4, 2
        j check_left
        
    #Get Left Char	(player.row, player.col-1)
    check_left:
        move $a0, $s0
        move $a1, $s2
        move $t0, $s3
        addi $t0, $t0, -1
        move $a2, $t0
        jal get_cell
        beq $v0, 'm', found_monster_left
        beq $v0, 'B', found_boss_left
        j check_right
    found_monster_left:
        addi $s4, $s4, 1
        j check_right
    found_boss_left:
        addi $s4, $s4, 2
        j check_right
    
    #Get Right Char	(player.row, player.col+1)
    check_right:
        move $a0, $s0
        move $a1, $s2
        move $t0, $s3
        addi $t0, $t0, 1
        move $a2, $t0
        jal get_cell
        beq $v0, 'm', found_monster_right
        beq $v0, 'B', found_boss_right
        j return_damage
    found_monster_right:
        addi $s4, $s4, 1
        j return_damage
    found_boss_right:
        addi $s4, $s4, 2
        j return_damage
    
    return_damage:
        move $v0, $s4
        
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $ra, 20($sp)
        addi $sp, $sp, 24

        jr $ra
# Part IX
player_move:
    addi $sp, $sp, -32
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $ra, 28($sp)
    
    move $s0, $a0		#s0 = map_ptr
    move $s1, $a1		#s1 = player_ptr
    move $s2, $a2		#s2 = target_row
    move $s3, $a3		#s3 = target_col
    lbu $s4, ($a1)		#s4 = player_ptr.row
    addi $a1, $a1, 1
    lbu $s5, ($a1)		#s5 = player_ptr.col
    
    move $a0, $s0
    move $a1, $s1
    jal monster_attacks
    
    move $t1, $s1		#t1 = copy of player_str
    addi $t1, $t1, 2		#move ptr to player heath
    lb $t0, ($t1)
    sub $t0, $t0, $v0
    sb $t0, ($t1)		#change the health and put back to player_ptr
    blez $t0, player_killed
    
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    jal get_cell
    move $s6, $v0			#s6 = target cell character
    beq $s6, '.', move_the_player
    beq $s6, '$', move_the_player
    beq $s6, '*', move_the_player
    beq $s6, '>', move_the_player
    j return_player_move
    
    move_the_player:
        move $a0, $s0			#set target cell to be @
        move $a1, $s2
        move $a2, $s3
        li $a3, '@'
        jal set_cell
        
        move $a0, $s0			#set orig @ to empty floor
        move $a1, $s4
        move $a2, $s5
        li $a3, '.'
        jal set_cell
        
        move $t0, $s1			#Update player position
        sb $s2, ($t0)
        addi $t0, $t0, 1
        sb $s3, ($t0)
        
        beq $s6, '.', move_to_empty_floor
        beq $s6, '$', move_to_coin
        beq $s6, '*', move_to_gem
        beq $s6, '>', move_to_exit
        
    move_to_empty_floor:		#Moving to empty floor, v0 = 0
        li $v0, 0
        j return_player_move
        
    move_to_coin:			#Moving to coin, coin += 5, v0 = 0
        move $t0, $s1
        addi $t0, $t0, 3
        lbu $t1, ($t0)
        addi $t1, $t1, 1
        sb $t1, ($t0)
        
        li $v0, 0
        j return_player_move
        
    move_to_gem:			#Moving to gem, coin += 5,  v0 = 0
        move $t0, $s1
        addi $t0, $t0, 3
        lbu $t1, ($t0)
        addi $t1, $t1, 5
        sb $t1, ($t0)
        
        li $v0, 0
        j return_player_move
        
    move_to_exit:			#Moving to exit, v0 = -1
        li $v0, -1
        j return_player_move
        
    player_killed:
        move $a0, $s0
        move $t2, $s1
        lbu $a1, ($t2)
        addi $t2, $t2, 1
        lbu $a2, ($t2)
        li $a3, 'X'
        jal set_cell
        
        li $v0, 0
        j return_player_move
        
    return_player_move:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $s5, 20($sp)
        lw $s6, 24($sp)
        lw $ra, 28($sp)
        addi $sp, $sp, 32
    
        jr $ra


# Part X
player_turn:
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $ra, 20($sp)
    
    move $s0, $a0			#s0 = map_ptr
    move $s1, $a1			#s1 = player_ptr
    move $s2, $a2			#s2 = direction char
    lbu $s3, ($a1)			#s3 = player.row
    addi $a1, $a1, 1
    lbu $s4, ($a1)			#s4 = player.col
    
    beq $a2, 'U', up_direction
    beq $a2, 'D', down_direction
    beq $a2, 'L', left_direction
    beq $a2, 'R', right_direction
    j invalid_direction
    
    up_direction:		#(player.row-1, player.col)
        move $a0, $s0
        addi $s3, $s3, -1
        move $a1, $s3		#player.row-1
        move $a2, $s4		#player.col
        jal get_cell
        beq $v0, -1, invalid_target_cell_or_wall
        beq $v0, '#', invalid_target_cell_or_wall
        
        j find_attack_target
        
    down_direction:		#(player.row+1, player.col)
        move $a0, $s0
        addi $s3, $s3, 1	
        move $a1, $s3		#player.row+1
        move $a2, $s4		#player.col
        jal get_cell
        beq $v0, -1, invalid_target_cell_or_wall
        beq $v0, '#', invalid_target_cell_or_wall
        
        j find_attack_target
        
    left_direction:		#(player.row, player.col-1)
        move $a0, $s0
        move $a1, $s3		#player.row
        addi $s4, $s4, -1
        move $a2, $s4		#player.col-1
        jal get_cell
        beq $v0, -1, invalid_target_cell_or_wall
        beq $v0, '#', invalid_target_cell_or_wall
        
        j find_attack_target
        
    right_direction:		#(player.row, player.col+1)
        move $a0, $s0
        move $a1, $s3		#player.row
        addi $s4, $s4, 1
        move $a2, $s4		#player.col+1
        jal get_cell
        beq $v0, -1, invalid_target_cell_or_wall
        beq $v0, '#', invalid_target_cell_or_wall
        
        j find_attack_target
        
        
    find_attack_target:
        #s3 = target.row		#s4 = target.col
        move $a0, $s0			#a0 = map_ptr
        move $a1, $s1			#a1 = player_ptr
        move $a2, $s2			#a2 = direction
        jal get_attack_target
        beq $v0, -1, no_attack_just_move	#if target cell is not m, B, or /
        
        move $a0, $s0			#a0 = map_ptr
        move $a1, $s1			#a1 = player_ptr
        move $a2, $s3			#a2 = target.row
        move $a3, $s4			#a3 = target.col
        jal complete_attack
        li $v0, 0
        j return_player_turn
        
        
    no_attack_just_move:
         move $a0, $s0			#a0 = map_ptr
         move $a1, $s1			#a1 = player_ptr
         move $a2, $s3			#a2 = target.row
         move $a3, $s4			#a3 = target.col
         jal player_move
         #return player_move's v0
         j return_player_turn
    
    invalid_direction:
        li $v0, -1
        j return_player_turn
        
    invalid_target_cell_or_wall:
        li $v0, 0
        j return_player_turn
        
    return_player_turn:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $ra, 20($sp)
        addi $sp, $sp, 24
        jr $ra

set_visited_status:
    li $t5, 8
    addi $a0, $a0, 1			#move pointer to col#
    lbu $t1, ($a0)			#t1 = C (number of col in map_ptr)
    mul $t1, $t1, $a1			#t1 = i*C
    add $t1, $t1, $a2			#t1 = i*C+j
    div $t1, $t5			#t1 divided by 8
    mfhi $t3				#t3 = remainder
    mflo $t4				#t4 = quotient
    add $a3, $a3, $t4			#byte X = the quotient of i*C+j
    lbu $t6, ($a3)			#load byte X
    li $t5, 7
    sub $t3, $t5, $t3			#t3 = 7 - remainder of i*C+j
    sllv $t5, $t6, $t3			#shift by the amount of 7 - remainder of i*C+j
    andi $t7, $t5, 0x80
    beq $t7, 0x80, current_already_visited
    xori $t5, $t5, 0x80			#flip the correct bit
    srlv $t5, $t5, $t3			#shift back to its position
    or $t5, $t5, $t6			#or the result of flipped bit to original byte
    sb $t5, ($a3)
    
    li $v0, 0
    jr $ra
    
    current_already_visited:
        li $v0, -1
        jr $ra
    
# Part XI
flood_fill_reveal:
    addi $sp, $sp, -40
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)
    sw $fp, 32($sp)
    sw $ra, 36($sp)
    
    move $fp, $sp		#set fp = sp for our loop
    move $s0, $a0		#a0 = map_ptr
    move $s1, $a1		#a1 = row
    move $s2, $a2		#a2 = col
    move $s3, $a3		#a3 = visited[][]
    
    bltz $a1, invalid_argument			#if row < 0, error
    lbu $t0, ($a0)			
    bge $a1, $t0, invalid_argument                #if row >= map.row, error
    
    bltz $a2, invalid_argument			#if col < 0, error
    addi $a0,$a0,1
    lbu $t0,($a0)
    bge $a2, $t0, invalid_argument			#if col >= map.col, error
    
    addi $sp, $sp, -8
    sw $s1, 0($sp)
    sw $s2, 4($sp)
    reveal_large_loop:
        beq $sp, $fp, completed			#if sp == fp, completed
        lw $s1, 0($sp)
        lw $s2, 4($sp)
        addi $sp, $sp, 8
        move $a0, $s0				#get the cell (row, col) visible
        move $a1, $s1				#s1 = row
        move $a2, $s2				#s2 = col
        jal get_cell
        andi $t0, $v0, 0x80
        beq $t0, 0x80, set_cell_visible
        #IF ALREADY VISIBLE, MAKE IT VISITED
        j set_current_visited
        
        set_cell_visible:
            xori $v0, $v0, 0x80			#flip the msb to 0 and make it visible
            move $a0, $s0
            move $a1, $s1
            move $a2, $s2
            move $a3, $v0
            jal set_cell
            j set_current_visited
            
        set_current_visited:
           move $a0, $s0			#a0 = map_ptr
           move $a1, $s1			#a1 = row
           move $a2, $s2			#a2 = col
           move $a3, $s3			#a3 = visited[][]
           jal set_visited_status
           j push_up_cell
       
        push_up_cell:	############# #UP (current_cell.row -1, current_cell.col) ##############
            move $s6, $s1			#s6 = row
            move $s7, $s2			#s7 = col
            move $a0, $s0
            addi $s6, $s6, -1			#s6 = row-1
            move $a1, $s6
            move $a2, $s7			#s7 = col
            jal get_cell
            beq $v0, '.', up_floor_set_visited
            beq $v0, 0xAE, up_floor_set_visited
            j push_down_floor				#if not empty floor, move down to check
       
       up_floor_set_visited:
           move $a0, $s0
           move $a1, $s6
           move $a2, $s7
           move $a3, $s3
           jal set_visited_status
           beq $v0, -1, up_floor_already_visited		#if empty floor already visited, don't push onto stack
           addi $sp, $sp, -8				#if not visited before, make it visited now and push it on to stack
           sw $s6, 0($sp)
           sw $s7, 4($sp)
       up_floor_already_visited:
           j push_down_floor
           
       push_down_floor:			############# #DOWN (current_cell.row +1, current_cell.col) ##############
           move $s6, $s1			#s6 = row
           move $s7, $s2			#s7 = col
           move $a0, $s0
           addi $s6, $s6, 1			#s6 = row+1
           move $a1, $s6
           move $a2, $s7			#s7 = col
           jal get_cell
           beq $v0, '.', down_floor_set_visited
           beq $v0, 0xAE, down_floor_set_visited
           j push_left_floor				#if not empty floor, move down to check
           
       down_floor_set_visited:
           move $a0, $s0
           move $a1, $s6
           move $a2, $s7
           move $a3, $s3
           jal set_visited_status
           beq $v0, -1, down_floor_already_visited		#if empty floor already visited, don't push onto stack
           addi $sp, $sp, -8				#if not visited before, make it visited now and push it on to stack
           sw $s6, 0($sp)
           sw $s7, 4($sp)
       down_floor_already_visited:
           j push_left_floor
       push_left_floor:			############# #LEFT (current_cell.row, current_cell.col-1) ##############
           move $s6, $s1			#s6 = row
           move $s7, $s2			#s7 = col
           move $a0, $s0
           move $a1, $s6
           addi $s7, $s7, -1
           move $a2, $s7			#s7 = col
           jal get_cell
           beq $v0, '.', left_floor_set_visited
           beq $v0, 0xAE, left_floor_set_visited
           j push_right_floor				#if not empty floor, move down to check
           
       left_floor_set_visited:
           move $a0, $s0
           move $a1, $s6
           move $a2, $s7
           move $a3, $s3
           jal set_visited_status
           beq $v0, -1, left_floor_already_visited		#if empty floor already visited, don't push onto stack
           addi $sp, $sp, -8				#if not visited before, make it visited now and push it on to stack
           sw $s6, 0($sp)
           sw $s7, 4($sp)
       left_floor_already_visited:
           j push_right_floor
           
       push_right_floor:		############# RIGHT # (current_cell.row, current_cell.col+1) ##############
           move $s6, $s1			#s6 = row
           move $s7, $s2			#s7 = col
           move $a0, $s0
           move $a1, $s6
           addi $s7, $s7, 1
           move $a2, $s7			#s7 = col
           jal get_cell
           beq $v0, '.', right_floor_set_visited
           beq $v0, 0xAE, right_floor_set_visited
           j reveal_large_loop				#if not empty floor, move down to check
       right_floor_set_visited:
           move $a0, $s0
           move $a1, $s6
           move $a2, $s7
           move $a3, $s3
           jal set_visited_status
           beq $v0, -1, reveal_large_loop		#if empty floor already visited, don't push onto stack
           addi $sp, $sp, -8				#if not visited before, make it visited now and push it on to stack
           sw $s6, 0($sp)
           sw $s7, 4($sp)
       right_floor_already_visited:
           j reveal_large_loop
           
    completed:
        #move $sp, $fp	#submitted on the hw, but this should be unnecessary
        li $v0, 0
        j finished
    
    invalid_argument:
        li $v0, -1
        j finished
        
    finished:
    	lw $s0, 0($sp)
    	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
    	lw $s5, 20($sp)
    	lw $s6, 24($sp)
    	lw $s7, 28($sp)
    	lw $fp, 32($sp)
    	lw $ra, 36($sp)
    	addi $sp, $sp, 40
        jr $ra
    
#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
