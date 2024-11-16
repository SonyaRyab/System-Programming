import random as rd

Variant = 15
rd.seed(Variant)

Numbers_of_problems = [i+1 for i in rd.sample(range(14),3)]
print(Numbers_of_problems)
