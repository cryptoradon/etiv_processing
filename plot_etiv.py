###
# This file takes in csv files containing etiv values and compares them in a linear regression graph.
###

import csv
import matplotlib.pyplot as plt
import numpy as np

def compareTwoETIVs(etiv_data_1, etiv_data_2):
    data1, data2 = {}, {}
    with open(etiv_data_1) as f1, open(etiv_data_2) as f2:
        reader1 = csv.reader(f1)
        reader2 = csv.reader(f2)

        for index, row in enumerate(reader1):
            if index == 0:
                continue
            id = row[0]
            data1[id] = row[-1]

        for index, row in enumerate(reader2):
            if index == 0:
                continue
            id = row[0]
            data2[id] = row[-1]

    maxDistID = -1
    maxDist = -1
    eTIV1 = []
    eTIV2 = []
    for id in data1:
        val1 = float(data1[id])
        val2 = float(data2[id])
        if np.abs(val1 - val2) > maxDist:
            maxDist = np.abs(val1 - val2)
            maxDistID = id
        eTIV1.append(val1)
        eTIV2.append(val2)

    print(f"The subject with the maximum distance {maxDist} is {maxDistID}")
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.scatter(eTIV1, eTIV2, color='slateblue', alpha=0.7, edgecolor='k', label='Subjects')

    min_etiv = min(eTIV1 + eTIV2)
    max_etiv = max(eTIV1 + eTIV2)
    ax.plot([min_etiv, max_etiv], [min_etiv, max_etiv], 'r--', label='Ideal (y=x)')

    coeffs = np.polyfit(eTIV1, eTIV2, deg=1)
    slope, intercept = coeffs
    reg_x = np.array([min_etiv, max_etiv])
    reg_y = slope * reg_x + intercept
    ax.plot(reg_x, reg_y, 'g-', label=f'Fit: y = {slope:.2f}x + {intercept:.2f}')
    ax.annotate(f'Max diff: {maxDistID}',
            xy=(eTIV1[np.argmax(np.abs(np.array(eTIV1) - np.array(eTIV2)))],
                eTIV2[np.argmax(np.abs(np.array(eTIV1) - np.array(eTIV2)))]),
            xytext=(5, -5), textcoords='offset points',
            fontsize=8, color='red')


    ax.set_title('eTIV Comparison with Regression')
    ax.set_xlabel(etiv_data_1.split("/")[-3])
    ax.set_ylabel(etiv_data_2.split("/")[-3])
    ax.set_xlim(min_etiv, max_etiv)
    ax.set_ylim(min_etiv, max_etiv)
    ax.set_aspect('equal')
    ax.grid(True)
    ax.legend()

    plt.tight_layout()
    plt.show()


if __name__ == '__main__':
    # freesurfer741Data = "/home/ahmadkhana/Desktop/etiv-comparison/freesurfer741/log/etiv_estimation.csv"
    # charmData = "/home/ahmadkhana/Desktop/etiv-comparison/charm/log/etiv_estimation.csv"
    # charmExtData = "/home/ahmadkhana/Desktop/etiv-comparison/charm_ext/log/etiv_estimation.csv"
    charmEveryNData = "/home/ahmadkhana/Desktop/etiv-comparison/charm/log/etiv_estimation_every_n.csv"
    charmExtEveryNData = "/home/ahmadkhana/Desktop/etiv-comparison/charm_ext/log/etiv_estimation_every_n.csv"
    groundTruthData = "/home/ahmadkhana/Desktop/etiv-comparison/charm_ext/log/etiv_estimation_ground_truth.csv"

    # compareTwoETIVs(etiv_data_1=charmData, etiv_data_2=freesurfer741Data)
    # compareTwoETIVs(etiv_data_1=charmExtData, etiv_data_2=freesurfer741Data)
    # compareTwoETIVs(etiv_data_1=charmExtData, etiv_data_2=charmData)
    compareTwoETIVs(etiv_data_1=groundTruthData, etiv_data_2=charmEveryNData)
    compareTwoETIVs(etiv_data_1=groundTruthData, etiv_data_2=charmExtEveryNData)