# Simple array methods

from typing import List, Union

# Reverse an array
def reverse(arr: Union[List[Union[int, float]], None]) -> List[Union[int, float]]:
    """
    Reverses the given array in place.

    Parameters:
    arr (List[Union[int, float]] | None): The array to reverse.

    Returns:
    List[Union[int, float]]: The reversed array or an empty list if input is None.
    """
    if arr is None:
        return []

    # Capture start and end indices and swap elements
    start, end = 0, len(arr) - 1

    while start < end:
        arr[start], arr[end] = arr[end], arr[start]
        start += 1
        end -= 1

    return arr


# Maximum subarray total using Kadane's algorithm
def max_subarray(arr: Union[List[Union[int, float]], None]) -> Union[int, float]:
    """
    Computes the maximum subarray sum using Kadane's algorithm.

    Parameters:
    arr (List[Union[int, float]] | None): The array to evaluate.

    Returns:
    Union[int, float]: The maximum subarray sum or 0 if input is None or empty.
    """
    if arr is None or len(arr) == 0:
        return 0

    max_current, max_final = arr[0], arr[0]

    for i in range(1, len(arr)):
        max_current = max(arr[i], arr[i] + max_current)
        max_final = max(max_current, max_final)

    return max_final


# Merge two sorted arrays
def merge_sorted(arr1: Union[List[Union[int, float]], None], arr2: Union[List[Union[int, float]], None]) -> List[Union[int, float]]:
    """
    Merges two sorted arrays into a single sorted array.

    Parameters:
    arr1 (List[Union[int, float]] | None): The first sorted array.
    arr2 (List[Union[int, float]] | None): The second sorted array.

    Returns:
    List[Union[int, float]]: The merged sorted array or an empty list if either input is None.
    """
    if arr1 is None or arr2 is None:
        return []

    merged = []
    i, j = 0, 0

    # Compare elements of both arrays and merge the smaller one
    while i < len(arr1) and j < len(arr2):
        if arr1[i] < arr2[j]:
            merged.append(arr1[i])
            i += 1
        else:
            merged.append(arr2[j])
            j += 1

    # Append any remaining elements from both arrays
    merged.extend(arr1[i:])
    merged.extend(arr2[j:])

    return merged

