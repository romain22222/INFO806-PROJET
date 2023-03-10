(in-package #:queen)

(in-readtable queen::syntax)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defconstant +MATK+ 10000)
  (defconstant +MATQ+ 900)
  (defconstant +MATR+ 500)
  (defconstant +MATB+ 330)
  (defconstant +MATN+ 320)
  (defconstant +MATP+ 100))

(defparameter +MAX-DEPTH+ 5)

(deftype score ()
  `(integer -32000 32000))

(defmacro defscore (name &body value)
  `(progn
     (declaim (type (simple-array (integer -100 100) (8 8)) ,name))
     (defparameter ,name
       (make-array '(8 8) :element-type '(integer -100 100)
                          :initial-contents
                          (reverse ',value)))))

(defscore *p-scores*
  ( 0   0   0   0   0   0   0   0)
  (50  50  50  50  50  50  50  50)
  (10  10  20  30  30  20  10  10)
  ( 5   5  10  25  25  10   5   5)
  ( 0   0   0  20  20   0   0   0)
  ( 5  -5 -10   0   0 -10  -5   5)
  ( 5  10  10 -20 -20  10  10   5)
  ( 0   0   0   0   0   0   0   0))

(defscore *n-scores*
  (-50 -40 -30 -30 -30 -30 -40 -50)
  (-40 -20   0   0   0   0 -20 -40)
  (-30   0  10  15  15  10   0 -30)
  (-30   5  15  20  20  15   5 -30)
  (-30   0  15  20  20  15   0 -30)
  (-30   5  10  15  15  10   5 -30)
  (-40 -20   0   5   5   0 -20 -40)
  (-50 -40 -30 -30 -30 -30 -40 -50))

(defscore *b-scores*
  (-20 -10 -10 -10 -10 -10 -10 -20)
  (-10   0   0   0   0   0   0 -10)
  (-10   0   5  10  10   5   0 -10)
  (-10   5   5  10  10   5   5 -10)
  (-10   0  10  10  10  10   0 -10)
  (-10  10  10  10  10  10  10 -10)
  (-10   5   0   0   0   0   5 -10)
  (-20 -10 -10 -10 -10 -10 -10 -20))

(defscore *r-scores*
  ( 0   0   0   0   0   0   0   0)
  ( 5  10  10  10  10  10  10   5)
  (-5   0   0   0   0   0   0  -5)
  (-5   0   0   0   0   0   0  -5)
  (-5   0   0   0   0   0   0  -5)
  (-5   0   0   0   0   0   0  -5)
  (-5   0   0   0   0   0   0  -5)
  ( 0   0   0   5   5   0   0   0))

(defscore *q-scores*
  (-20 -10 -10  -5  -5 -10 -10 -20)
  (-10   0   0   0   0   0   0 -10)
  (-10   0   5   5   5   5   0 -10)
  ( -5   0   5   5   5   5   0  -5)
  (  0   0   5   5   5   5   0  -5)
  (-10   5   5   5   5   5   0 -10)
  (-10   0   5   0   0   0   0 -10)
  (-20 -10 -10  -5  -5 -10 -10 -20))

(defscore *k-scores-opening*
  (-30 -40 -40 -50 -50 -40 -40 -30)
  (-30 -40 -40 -50 -50 -40 -40 -30)
  (-30 -40 -40 -50 -50 -40 -40 -30)
  (-30 -40 -40 -50 -50 -40 -40 -30)
  (-20 -30 -30 -40 -40 -30 -30 -20)
  (-10 -20 -20 -20 -20 -20 -20 -10)
  ( 20  20   0   0   0   0  20  20)
  ( 20  30  10   0   0  10  30  20))

(defscore *k-scores-ending*
  (-50 -40 -30 -20 -20 -30 -40 -50)
  (-30 -20 -10   0   0 -10 -20 -30)
  (-30 -10  20  30  30  20 -10 -30)
  (-30 -10  30  40  40  30 -10 -30)
  (-30 -10  30  40  40  30 -10 -30)
  (-30 -10  20  30  30  20 -10 -30)
  (-30 -30   0   0   0   0 -30 -30)
  (-50 -30 -30 -30 -30 -30 -30 -50))

(defun piece-value (piece)
  (declare (optimize speed)
           (type piece piece))
  (ecase (piece piece)
    (#.+PAWN+   +MATP+)
    (#.+KNIGHT+ +MATN+)
    (#.+BISHOP+ +MATB+)
    (#.+ROOK+   +MATR+)
    (#.+QUEEN+  +MATQ+)
    (#.+KING+   +MATK+)))

(declaim (type (function () score) get-score))
(defun get-score (piece row col &optional ending)
  (declare (optimize speed)
           (type piece piece)
           (type (integer 0 7) row col))
  (unless (is-white? piece)
    (setf row (- 7 row)
          col (- 7 col)))
  (ecase (piece piece)
    (#.+PAWN+   (+ +MATP+ (aref *p-scores* row col)))
    (#.+KNIGHT+ (+ +MATN+ (aref *n-scores* row col)))
    (#.+BISHOP+ (+ +MATB+ (aref *b-scores* row col)))
    (#.+ROOK+   (+ +MATR+ (aref *r-scores* row col)))
    (#.+QUEEN+  (+ +MATQ+ (aref *q-scores* row col)))
    (#.+KING+   (+ +MATK+ (aref (if ending
                                    *k-scores-ending*
                                    *k-scores-opening*) row col)))))

(declaim (type (function () score) static-value))
(defun static-value (game)
  (declare (optimize speed)
           (type game game))
  (let ((total 0)
        (kr1 0) (kc1 0) (kr2 0) (kc2 0)
        (m1 0) (m2 0)
        (our-side (game-side game)))
    (declare (type score total m1 m2)
             (type (integer 0 7) kr1 kc1 kr2 kc2))
    (board-foreach
     (game-board game)
     (lambda (piece row col index)
       (declare (ignore index))
       (cond
         ((is-king? piece)
          (cond
            ((same-side? piece our-side)
             (setf kr1 row kc1 col))
            (t
             (setf kr2 row kc2 col))))
         (t
          (let ((score (get-score piece row col)))
            (if (same-side? piece our-side)
                (progn
                  (incf total score)
                  (unless (logtest piece +PAWN+)
                    (incf m1 (piece-value piece))))
                (progn
                  (decf total score)
                  (unless (logtest piece +PAWN+)
                    (incf m2 (piece-value piece))))))))))
    (let ((end-game (and (< m1 #.(+ +MATQ+ +MATR+))
                         (< m2 #.(+ +MATQ+ +MATR+)))))
      (incf total (get-score (logior +KING+ our-side)
                             kr1 kc1 end-game))
      (decf total (get-score (logxor (logior +KING+ our-side) our-side)
                             kr2 kc2 end-game)))
    total))

(defun move-value (move)
  (declare (optimize speed)
           (type move move))
  (let ((score (piece-value (move-piece move))))
    (declare (type fixnum score))
    (awhen (move-captured-piece move)
      (setf score (+ 10000 (piece-value it))))
    (awhen (move-promoted-piece move)
      (incf score (+ 15000 (piece-value it))))
    (when (move-check? move)
      (incf score 20000))
    score))

(defun sort-moves (moves)
  (stable-sort moves
               (lambda (m1 m2)
                 (> (move-value m1)
                    (move-value m2)))))

(defun quies-moves (moves)
  (sort-moves (remove-if-not (lambda (m)
                               (or (move-capture? m)
                                   (move-promote? m)
                                   ;; (move-check? m)
                                   ))
                             moves)))

(declaim (type (function () score) quies))
(defun quies (game ?? ?? moves pline)
  (declare (optimize speed)
           (type game game)
           (type score ?? ??)
           (type list moves)
           (type cons pline))
  (let ((score (static-value game)))
    (when (>= score ??)
      (return-from quies ??))
    (when (> score ??)
      (setf ?? score))
    (if (null moves)
        (if (attacked? game)
            -15000
            (- ??))
        (loop for move in (quies-moves moves)
              for line = (cons nil nil)
              do (with-move (game move t)
                   (setf score (- (quies game (- ??) (- ??)
                                         (game-compute-moves game)
                                         line))))
                 (when (>= score ??)
                   (return ??))
                 (when (> score ??)
                   (setf ?? score)
                   (setf (car pline) (cons move (car line))))
              finally (return ??)))))

(declaim (type (function () score) pvs))
(defun pvs (game start-depth ?? ?? pline)
  (declare (optimize speed)
           (type game game)
           (type (unsigned-byte 8) start-depth)
           (type score ?? ??)
           (type cons pline))
  (labels
      ((rec (depth ?? ?? pline)
         (declare (type (unsigned-byte 8) depth)
                  (type score ?? ??)
                  (type cons pline))
         (let ((moves (if (= depth start-depth)
                          (init-moves game)
                          (sort-moves (game-compute-moves game)))))
           (cond
             ((null moves)
              (if (attacked? game)
                  ;; for a checkmate, subtract depth so that shallow
                  ;; checkmates score better
                  (- -15000 depth)
                  ;; for a stalemate, negate the static board value -- we'd
                  ;; like to go for draw if we score lower than the opponent.
                  (- (static-value game))))
             ((zerop depth)
              ;; somehow SBCL doesn't figure out that QUIES returns a SCORE
              (the score (- (quies game ?? ?? moves pline) depth)))
             (t
              (let ((score 0))
                (declare (type score score))
                (loop for first = t then nil
                      for line = (cons nil nil)
                      for move in moves do
                        ;; (when (= depth 5)
                        ;;   (format t "Researching: ~A (~A..~A ~A)~%"
                        ;;           (dump-line game (list move))
                        ;;           ?? ?? score))
                        (with-move (game move t)
                          (cond
                            (first
                             (setf score (- (rec (1- depth) (- ??) (- ??) line))))
                            (t
                             (setf score (- (rec (1- depth) (- 0 ?? 1) (- ??) line)))
                             (when (< ?? score ??)
                               (setf score (- (rec (1- depth) (- ??) (- score) line)))))))
                        (when (> score ??)
                          (setf ?? score)
                          (setf (car pline) (cons move (car line))))
                        (when (>= ?? ??)
                          (return-from rec ??))))
              ??)))))
    (rec start-depth ?? ?? pline)))

(defun init-moves (game &optional (depth 2))
  (labels ((score (depth ?? ??)
             (let ((moves (sort-moves (game-compute-moves game))))
               (cond
                 ((null moves)
                  (if (attacked? game)
                      (- -15000 depth)
                      (- (static-value game))))
                 ((zerop depth)
                  (static-value game))
                 (t
                  (loop for m in moves
                        for score = (with-move (game m)
                                      (- (score (1- depth) (- ??) (- ??))))
                        finally (return ??)
                        when (> score ??)
                          do (setf ?? score)
                        when (>= ?? ??)
                          do (return ??)))))))
    (let ((scores (loop for m in (sort-moves (game-compute-moves game))
                        collect (cons m (with-move (game m)
                                          (score depth -32000 32000))))))
      (mapcar #'car
              (stable-sort scores
                           (lambda (c1 c2)
                             (< (cdr c1) (cdr c2))))))))

(defun game-search (game &optional (depth +MAX-DEPTH+))
  (let* ((line (cons nil nil))
         (score (pvs game depth -32000 +32000 line)))
    (values (car line) score)))

(defun dump-line (game moves)
  (with-output-to-string (out)
    (labels ((rec (moves first)
               (when moves
                 (let ((move (car moves)))
                   (when (or first (move-white? move))
                     (unless first
                       (write-char #\SPACE out))
                     (format out "~D." (game-fullmove game)))
                   (when (and first (move-black? move))
                     (format out ".."))
                   (format out " ~A" (game-san game move))
                   (with-move (game move)
                     (rec (cdr moves) nil))))))
      (rec moves t))))

(defun play (&key
               (fen +FEN-START+)
               (depth +MAX-DEPTH+))
  (let ((game (make-game))
        (history (list)))
    (reset-from-fen game fen)
    (flet ((computer-move ()
             (format t "...thinking...~%")
             (multiple-value-bind (line score)
                 (game-search game depth)
               (cond
                 ((null line)
                  (format t "No moves found~%"))
                 (t
                  (format t "Computer: ~A (score ~A)~%"
                          (dump-line game line) score)
                  (push (car line) history)
                  (game-move game (car line))))))
           (finished? ()
             (let ((moves (game-compute-moves game)))
               (cond
                 ((null moves)
                  (if (attacked? game) :checkmate :stalemate))
                 ((draw-by-material? game)
                  :draw)))))

      (loop
        (awhen (finished?)
          (format t "Game ended: ~A~%" it))
        (print-board (game-board game))
        (format t "~A: " (if (is-white? (game-side game))
                             "White" "Black"))
        (finish-output)
        (let ((line (read-line *standard-input* nil)))
          (cond
            ((null line)
             (return))

            ((string= line ""))

            ((or (string= line "exit")
                 (string= line "end"))
             (return))

            ((string= line "go")
             (computer-move))

            ((string= line "restart")
             (reset-from-fen game fen)
             (setf history (list)))

            ((string= line "reset")
             (reset-game game)
             (setf fen +FEN-START+
                   history (list)))

            ((string= line "undo")
             (pop history)
             (reset-from-fen game fen)
             (mapc (lambda (move)
                     (game-move game move))
                   (reverse history)))

            ((string= line "pgn")
             (let ((game (make-game)))
               (reset-from-fen game fen)
               (let ((*unicode* nil))
                 (format t "~A~%" (dump-line game (reverse history))))))

            ((string= line "fen")
             (let ((*unicode* nil))
               (format t "~A~%" (game-fen game))))

            (t
             (let ((moves (game-parse-san game line)))
               (cond
                 ((null moves)
                  (format t "Invalid move: ~A~%" line))
                 ((> (length moves) 1)
                  (format t "Ambiguous move: ~{~A~^, ~}~%"
                          (mapcar (lambda (m)
                                    (game-san game m))
                                  moves)))
                 (t
                  (push (car moves) history)
                  (game-move game (car moves))
                  (print-board (game-board game))
                  (computer-move)))))))

        (format t "~%")))))
