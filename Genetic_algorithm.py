
from copy import deepcopy
import subprocess
import random

COUNT_MAX = 50
CHANCE_OF_CONCATENATION = 2
MIN_WANTED = -15

# 1st compilation (to be sure the testbench and the arbiter are well compiled)
ls = subprocess.run(['/Questa/questasim/bin/vcom', '-work', '{lib}', '{dir}/arb_tb_fuzzer.vhd'])
ls = subprocess.run(['/Questa/questasim/bin/vcom', '-work', '{lib}', '{dir}/arb.vhd'])


def writing_sequences (array):
    for i in range(len(array)):
      writing_file.write(str(bin(array[i]))[2::].zfill(4) + "\n") #writes sequences to a file
      
      # Array[i] is an int so we need to convert it to binary with bin(). This will give "0b0000" so if we want to take only the binary, we use : [2::]. zfill is used to add 0s if binary is < 8 and have at any case a 4 -bit input(print 0000 instead of 0)
      
    writing_file.write("Done\n") # Used to separate sequence in the file



def genetic_operation(array):
  array_modified = deepcopy(array) #deepcopy is used to copy the array and do some modification on array1 without modify the first array
  if random.randrange(0, CHANCE_OF_CONCATENATION,1) == 1 : # 1 chance in CHANCE_OF_CONCATENATION of concatenate 2 random array from matrix
   array_modified = matrix[random.randrange(0, 10,1)] + matrix[random.randrange(0, 10,1)]
  
  else:

    for j in range(len(array_modified)):
      if array_modified[j] != 0: # Used to not touch the line with "0000" (easier to work only with valid inputs)
          if random.randrange(0, 2,1) == 1: # 1 in 2 chance to use OR 
            a = array_modified[j] | random.randrange(1, 16,1)
            
          else : # 1 in 2 chance to use AND 
          
            a = array_modified[j] & random.randrange(9, 16,1) # Starts with 9 because if we do & with a number <9, this will necessarily be an invalid command (because cmd=0)
            
          if a > 8: # Ensures that there is req !=0 and cmd = 1 (if this is not the case, the command is invalid so we don't change the previous value)
            array_modified[j] = a
          if random.randrange(0,4,1) == 1: # 1 chance in 4 of adding a certain number of "0000"  (between 1 and 3) without corrupting the validity of the sequence
            array_modified = array_modified[:j+1] + [0]*random.randrange(1,3,1) + array_modified[j+1:]

  return array_modified


 
# initial sequences
# All sequences must end with a 0 to facilitate concatenation between 2 sequences and keep the validity of the sequences. 9 is the lowest valid with a cmd = 1 and req !=0
array  = [9,0] 
array1 = [9,0]
array2 = [9,0]
array3 = [9,0]
array4 = [9,0]
array5 = [9,0]
array6 = [9,0]
array7 = [9,0]
array8 = [9,0]
array9 = [9,0]
array_modified  = []
array_modified1 = []
array_modified2 = []
array_modified3 = []
array_modified4 = []
array_modified5 = []
array_modified6 = []
array_modified7 = []
array_modified8 = []
array_modified9 = []

Min = False

count = 0

matrix =   [array, array1, array2, array3,array4, array5,array6, array7,array8, array9]
matrix_modified = [array_modified,array_modified1,array_modified2,array_modified3,array_modified4,array_modified5,array_modified6,array_modified7,array_modified8,array_modified9]



# 1st evaluation 
with open("sequences.txt", 'w') as writing_file: # Writes all sequences to a file
  for i in range(len(matrix)):
    writing_sequences (matrix[i])
  
ls = subprocess.run(['/Questa/questasim/bin/vsim', '-batch', '-do', 'modelsim_command.do']) # Executes the modelsim command from modelsim_command.do (simulation, run and quit)

with open("results.txt", 'r') as reading_file: # Reads simulation results
  results_string = reading_file.read().splitlines() 

results_int = [eval(i) for i in results_string] # Converts string to int to sort


for i in range(len(results_int)) : # Checks if there is an overflaw in the results obtained
    
   if results_int[i] <= MIN_WANTED:
      
     Min = True
     Min_index = i
     break
     








while not(Min) and count < COUNT_MAX: # Loop until we found an overflaw or until a certain amount of test

  count = count +1 

  # Modifies the 10 best previous sequences. Stores the results in 10 other arrays which gives 20 arrays (20 sequences)
  for i in range(len(matrix)):
    matrix_modified[i]  = genetic_operation(matrix[i])
 
  with open("sequences.txt", 'w') as writing_file: # Writes the 10 new sequences to a file
   for i in range(len(matrix_modified)):
    writing_sequences (matrix_modified[i])
    
  # Simulates the 10 new sequences
  ls = subprocess.run(['/Questa/questasim/bin/vsim', '-batch', '-do', 'modelsim_command.do'])
  
  
  with open("results.txt", 'r') as reading_file: # Reads simulation results
   results_modified_string = reading_file.read().splitlines()

  results_modified_int = [eval(i) for i in results_modified_string] # Converts string to int to sort
  
  results_final = results_int + results_modified_int # Adds new results to old ones
  final_matrix = matrix + matrix_modified # Adds new sequences to old ones

  
  matrix_and_number = list(zip(final_matrix, results_final)) # Associates each sequence with its score
  matrix_and_number = sorted(matrix_and_number, key=lambda x: x[1]) # Sorts the sequences according to their score

  matrix = [t for t, _ in matrix_and_number][:10] # Keeps the first 10 sequences
  results_int = [n for _, n in matrix_and_number][:10] # Keeps the scores of the first 10 sequences

  for i in range(len(results_int)) : # Checks if there is an overflaw in the results obtained
    
   if results_int[i] <= MIN_WANTED:
      
     Min = True
     Min_index = i
     break
     



if count == COUNT_MAX:
  print("no problem dandected")
  
  
else:
  print(f"Problem detected during test number {count} with this sequence:")
  for i in range(len(matrix[Min_index])):
   print (str(bin(matrix[Min_index][i]))[2::].zfill(4))

  


    
  
   