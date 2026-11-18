;;; gezira-library.l -- a Gezira that's libgezira and libnile, loaded as libraries (libgezira.k, libnile.k): each path a
;;; pipeline of TransformBeziers, ClipBeziers, Rasterize and a composite over the image, as test-gezira.k draws.
;;; (gezira-library image process) makes one; init-libgezira must have loaded the libraries.
(require "libgezira.k")

(define-structure <gezira-library> (image process))
(define-function gezira-library (image process) (new <gezira-library> image process))

(define-method gezira-fill-path <gezira-library> (m width height paint floats count)
  (nile_Process_feed
   (nile_Process_pipe
    (gezira_TransformBeziers self.process (<ks-matrix>-a m) (<ks-matrix>-b m) (<ks-matrix>-c m)
			     (<ks-matrix>-d m) (<ks-matrix>-e m) (<ks-matrix>-f m))
    (gezira_ClipBeziers self.process 0.0 0.0 (* 1.0 width) (* 1.0 height))
    (gezira_Rasterize self.process)
    (gezira_CompositeUniformColorOverImage_ARGB32 self.process self.image
						  (cadr paint) (caddr paint) (cadddr paint) (car (cddddr paint)))
    0)
   floats count))

;; inside clipping stages (gezira.l): a TransformBeziers and a ClipBeziers for each, outermost nearest the image
(define-method gezira-fill-clipped <gezira-library> (m stages width height paint floats count)
  (let ((out (nile_Process_pipe
	      (gezira_ClipBeziers self.process 0.0 0.0 (* 1.0 width) (* 1.0 height))
	      (gezira_Rasterize self.process)
	      (gezira_CompositeUniformColorOverImage_ARGB32 self.process self.image
							    (cadr paint) (caddr paint) (cadddr paint) (car (cddddr paint)))
	      0)))
    (list-do st stages
      (let ((s (car st)) (r (cdr st)))
	(set out (nile_Process_pipe
		  (gezira_ClipBeziers self.process (* 1.0 (car r)) (* 1.0 (cadr r)) (* 1.0 (caddr r)) (* 1.0 (cadddr r)))
		  (gezira_TransformBeziers self.process (<ks-matrix>-a s) (<ks-matrix>-b s) (<ks-matrix>-c s)
					   (<ks-matrix>-d s) (<ks-matrix>-e s) (<ks-matrix>-f s))
		  out 0))))
    (nile_Process_feed
     (nile_Process_pipe
      (gezira_TransformBeziers self.process (<ks-matrix>-a m) (<ks-matrix>-b m) (<ks-matrix>-c m)
			       (<ks-matrix>-d m) (<ks-matrix>-e m) (<ks-matrix>-f m))
      out 0)
     floats count)))
