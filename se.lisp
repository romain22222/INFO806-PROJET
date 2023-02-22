(require "asdf")
(push "C:/Users/romro/Documents/M1/info806/Projet/chessParser/" asdf:*central-registry*)
(push "C:/Users/romro/Documents/M1/info806/Projet/named-readtables-master/" asdf:*central-registry*)
(push "C:/Users/romro/Documents/M1/info806/Projet/anaphora-master/" asdf:*central-registry*)
(push "C:/Users/romro/Documents/M1/info806/Projet/alexandria-master/" asdf:*central-registry*)
(push "C:/Users/romro/Documents/M1/info806/Projet/cl-ppcre-master/" asdf:*central-registry*)
(push "C:/Users/romro/Documents/M1/info806/Projet/cl-unicode-master/" asdf:*central-registry*)
(push "C:/Users/romro/Documents/M1/info806/Projet/flexi-streams-1.0.19/" asdf:*central-registry*)
(push "C:/Users/romro/Documents/M1/info806/Projet/trivial-gray-streams-master/" asdf:*central-registry*)
(asdf:load-system "queen")


(defvar x (queen:parse-pgn ))
