import random as rd

Variant = 15
rd.seed(Variant)

Numbers_of_problems = [rd.sample(range(5),1)[0]+1, rd.sample(range(5),1)[0]+1, rd.sample(range(5),1)[0]+1]
print(Numbers_of_problems)