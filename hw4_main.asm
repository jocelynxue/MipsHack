.data
map_filename: .asciiz "map3.txt"
# num words for map: 45 = (num_rows * num_cols + 2) // 4 
# map is random garbage initially
.asciiz "Don't touch this region of memory"
map: .word 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 
.asciiz "Don't touch this"
# player struct is random garbage initially
player: .word 0x2912FECD
.asciiz "Don't touch this either"
# visited[][] bit vector will always be initialized with all zeroes
# num words for visited: 6 = (num_rows * num*cols) // 32 + 1
visited: .word 0 0 0 0 0 0 
.asciiz "Really, please don't mess with this string"

welcome_msg: .asciiz "Welcome to MipsHack! Prepare for adventure!\n"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz " Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"


num_rows: .asciiz "\nNum of Rows in Game: "
num_cols: .asciiz "\nNum of Cols in Game: "
cells: .asciiz "\nCells Info in Game: "
.text
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PRINTING THE MAP @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
print_map:
la $t0, map  # the function does not need to take arguments
li $v0, 4
la $a0, num_rows
syscall
lbu $t1, ($t0)			#t1 = # of row
li $v0, 1
move $a0, $t1
syscall
li $v0, 4
la $a0, num_cols
syscall
addi $t0, $t0, 1
lbu $t2, ($t0)			#t2 = # of col
li $v0, 1
move $a0,$t2
syscall
li $v0, 11
li $a0, '\n'
syscall
addi $t0, $t0, 1		#t0 = addr of game cell[0][0]

li $t3, 0			#row counter
cell_row_loop:
    beq $t3, $t1, exit_cell_row_loop
    li $t4, 0			#col counter
    cell_col_loop:
        beq $t4, $t2, exit_cell_col_loop
        lbu $t5, ($t0)
        andi $t6, $t5, 0x80
        beq $t6, 0x80, print_space
        li $v0, 11
        move $a0, $t5
        syscall
        addi $t4, $t4, 1
        addi $t0, $t0, 1
        j cell_col_loop
        
        print_space:
            li $v0, 11
            li $a0, '-'
            syscall
            addi $t0, $t0, 1
            addi $t4, $t4, 1
            j cell_col_loop
        
        
    exit_cell_col_loop:
        li $v0, 11
        li $a0, '\n'
        syscall
        addi $t3, $t3, 1
        j cell_row_loop
    
exit_cell_row_loop:
    jr $ra
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PRINTING THE MAP @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

#************************************************ CHECKING FOR PART 1***************************************************#
check_part_1:
la $t0, map  # the function does not need to take arguments
li $v0, 4
la $a0, num_rows
syscall
lbu $t1, ($t0)			#t1 = # of row
li $v0, 1
move $a0, $t1
syscall
li $v0, 4
la $a0, num_cols
syscall
addi $t0, $t0, 1
lbu $t2, ($t0)			#t2 = # of col
li $v0, 1
move $a0,$t2
syscall
li $v0, 11
li $a0, '\n'
syscall
addi $t0, $t0, 1		#t0 = addr of game cell[0][0]

li $t3, 0			#row counter
cell_row_loop1:
    beq $t3, $t1, exit_cell_row_loop1
    li $t4, 0			#col counter
    cell_col_loop1:
        beq $t4, $t2, exit_cell_col_loop1
        lbu $t5, ($t0)
        xori $t5, $t5, 0x80
        
        li $v0, 11
        move $a0, $t5
        syscall
        addi $t4, $t4, 1
        addi $t0, $t0, 1
        j cell_col_loop1
        
    exit_cell_col_loop1:
        li $v0, 11
        li $a0, '\n'
        syscall
        addi $t3, $t3, 1
        j cell_row_loop1
    
exit_cell_row_loop1:
    jr $ra
#************************************************ CHECKING FOR PART 1***************************************************#

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PRINTING THE PLAYER @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
print_player_info:
# the idea: print something like "Pos=[3,14] Health=[4] Coins=[1]"
la $t0, player
la $t2, pos_str
li $v0, 4
move $a0, $t2
syscall

lbu $t1, ($t0)
li $v0, 1
move $a0, $t1
syscall

li $v0, 11
li $a0, 44
syscall

addi $t0, $t0, 1
lbu $t1, ($t0)
li $v0, 1
move $a0, $t1
syscall


la $t2, health_str
li $v0, 4
move $a0, $t2
syscall
addi $t0, $t0, 1
lb $t1, ($t0)
li $v0, 1
move $a0, $t1
syscall

la $t2, coins_str
li $v0, 4
move $a0, $t2
syscall
addi $t0, $t0,1
lbu $t1, ($t0)
li $v0, 1
move $a0, $t1
syscall

li $v0, 11
li $a0, ']'
syscall
jr $ra

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PRINTING THE PLAYER @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

.globl main
main:
la $a0, welcome_msg
li $v0, 4
syscall

######################################PART1##########################################  ******
# fill in arguments
la $a0, map_filename
la $a1, map
la $a2, player
jal init_game
jal print_player_info
jal print_map
jal check_part_1
######################################PART2##########################################
#la $a0, map
#li $a1, 5
#li $a2, 3
#jal is_valid_cell

######################################PART3##########################################
#la $a0, map
#li $a1, 4
#li $a2, 6
#jal get_cell

######################################PART4##########################################
#la $a0, map
#li $a1, 0
#li $a2, 3
#li $a3, '*'
#jal set_cell

######################################PART5##########################################	*******
# fill in arguments
la $a0, map
li $a1, 3		#3
li $a2, 2		#2
jal reveal_area
jal print_player_info
jal print_map
######################################PART6##########################################
#la $a0, map
#la $a1, player
#li $a2, 'U'
#jal get_attack_target

######################################PART7##########################################

#la $a0, map
#la $a1, player
#li $a2, 3
#li $a3, 2
#jal complete_attack
#jal print_player_info
#jal print_map

######################################PART8##########################################
#la $a0, map
#la $a1, player
#jal monster_attacks
#jal print_player_info
#jal print_map

######################################PART9##########################################
#jal print_player_info
#jal print_map
#la $a0, map
#la $a1, player
#li $a2, 2
#li $a3, 3
#jal player_move
#jal print_player_info
#jal print_map

######################################PART10##########################################
#jal print_player_info
#jal print_map
#la $a0, map
#la $a1, player
#li $a2, 'R'
#jal player_turn
#jal print_player_info
#jal print_map

######################################PART11##########################################
la $a0, map
li $a1, 3
li $a2, 2
la $a3, visited
jal flood_fill_reveal
jal print_player_info
jal print_map

li $s0, 0  # move = 0

game_loop:  # while player is not dead and move == 0:

jal print_map # takes no args

jal print_player_info # takes no args

# print prompt
la $a0, your_move_str
li $v0, 4
syscall

li $v0, 12  # read character from keyboard
syscall
move $s1, $v0  # $s1 has character entered
li $s0, 0  # move = 0

li $a0, '\n'
li $v0 11
syscall

# handle input: w, a, s or d
# map w, a, s, d  to  U, L, D, R and call player_turn()

# if move == 0, call reveal_area()  Otherwise, exit the loop.

j game_loop

game_over:
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall

# choose between (1) player dead, (2) player escaped but lost, (3) player escaped and won

won:
la $a0, you_won_str
li $v0, 4
syscall
j exit

failed:
la $a0, you_failed_str
li $v0, 4
syscall
j exit

player_dead:
la $a0, you_died_str
li $v0, 4
syscall

exit:
li $v0, 10
syscall

.include "hw4.asm"
