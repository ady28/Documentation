#!/usr/bin/env python3

import random

lives = 5
word_list = ["car","house","mouse","cat"]
chosen_word = random.choice(word_list)
display = []
for _ in chosen_word:
    display += "_"
print(display)

end_of_game = False
won = False
while end_of_game == False:
    print(f"you have {lives} lives")
    guess = input("Enter a letter: ").lower()
    found = False
    for i in range(0,len(chosen_word)):
        if guess == chosen_word[i]:
            display[i] = guess
            found = True
    if found == False:
        lives-=1
    if lives == 0:
        end_of_game = True
    else:
        print(display)
        if "_" not in display:
            end_of_game = True
            won = True

if won == True:
    print("You have won!!")
else:
    print("You have lost!!")
