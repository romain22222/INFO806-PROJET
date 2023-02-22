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

(defun get-file (filename)
  (with-open-file (stream filename)
    (let ((lines ()))
    (loop for line = (read-line stream nil)
          while line do
          (push line lines))
    (reverse lines))
    )
  )

(defun concatMid (ls)
 (setq ld '(""))
 (dolist (l ls)
    (cond
     ((string= (car ld) "") (setq ld (cons (concatenate 'string (car ld) (cond ((string= (car ld) "") "") (T "~%~%")) l) (cdr ld))))
     (T (setq ld (cons (concatenate 'string (car ld) (cond ((string= (car ld) "") "") (T "~%~%")) l) (cdr ld))) (setq ld (cons "" ld)))
     )
)
  (reverse (cdr ld))
)

(defun concatGames (gamelines)
   (setq tabGames '())
   (setq tempC '())
   (setq emptyLine (nth (- (length gamelines) 1) gamelines))
    (dolist (l gamelines)
    (print tempC)
    (print "BANANA")
    (cond
     ((string= l emptyLine)
        ((setq tabGames (cons (concatenate 'string (reverse temC)) tabGames)) (setq temC '())))
      (T
        (setq tempC (cons l tempC)))
     )
   )
  (concatMid (reverse tabGames))
)

(defun loadGamesFromPGN (pgnPath)
  (concatGames (get-file pgnPath))
  )

;(format t "~A~%" (loadGamesFromPGN "C:/Users/romro/Documents/M1/info806/Projet/test.pgn"))

;(print (car (get-file "C:/Users/romro/Documents/M1/info806/Projet/test.pgn")))
;(print (concatGames (get-file "C:/Users/romro/Documents/M1/info806/Projet/test.pgn")))

;(format t "~A~%" (queen:parse-pgn ))


