# Simple array methods

# Reverse an array

def reverse(arr):
    if arr is None:
        return 0
    

    # cacth start and end index and switch it with each other

    (start, end) = (0, len(arr) - 1)

    while start < end:
        (arr[start], arr[end]) = (arr[end], arr[start])
        start += 1
        end -= 1


    return arr



# Maximum subarry total = kandal algorism 

def max_Subarray(arr):
    if arr is None:
        return 0
    
    (maxNow, MaxFinal) = (arr[0], arr[0])

    for i in range(1, len(arr)):
        maxNow = max(arr[i], arr[i] + maxNow)
        MaxFinal = max(maxNow, MaxFinal)

    return MaxFinal



# Merge two sorted arrays 
def mergeSorted(arr1, arr2):
    if arr1 is None or arr2 is None:
        return 0
    
    merged = []
    i, j = 0 , 0

    # compairing the two array elements and merge the smaller one 
    while i < len(arr1) and j < len(arr2):
        if arr1[i] < arr2[j]:
            merged.append(arr1[i])
            i += 1
        else:
            merged.append(arr2[j])
            j +=1


    # if there are any leftovers after i and j
    merged.append(arr1[i:])
    merged.append(arr2[j:])

    return merged

