lines = []
with open("C:\\Users\\romro\\Documents\\M1\\info806\\Projet\\DATABASE4U.pgn", 'r', encoding="ISO-8859-1") as f:
    for i in range(10000):
        lines.append(f.readline())
isp = False
parties = []
tmpP = ""
for l in lines:
    if l == "\n":
        if isp:
            parties.append(tmpP)
            tmpP = ""
        else:
            tmpP += " "
        isp = not isp
    else:
        tmpP += l.replace("\"","\\\"").replace("\n","") + " "

lispS = []
for i in range(len(parties)):
    lispS.append("(defvar g" + str(i) + " (queen:parse-pgn \"" + parties[i] + "\"))")

with open("C:\\Users\\romro\\Documents\\M1\\info806\\Projet\\testParsed.lst", 'w', encoding="ISO-8859-1") as f:
    for l in lispS:
        f.write(l + "\n")
