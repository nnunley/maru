;;; ollama.l: asks a model through a local Ollama server's /api/chat, which reaches its cloud models itself, so Maru needs
;;; no TLS.  What a prompt holds leaves the machine when the model is a cloud one: public text only.
;;;   (ollama-chat messages)  messages are ((role . text) ...), oldest first; answers the reply's text, or () if the
;;;                           server can't be reached, answers anything but 200, or sends what isn't a reply
;;;   (ollama-ask prompt)     one user message
;;; HTTP/1.0, so the server closes the connection after the reply and sends the body whole, never chunked.
(require "socket.l")
(require "json.l")
(require "recover.l")
(define *ollama-port* 11434)
(define *ollama-model* "deepseek-v4.1-flash:cloud")
(define *ollama-seconds* 180)
(define *ollama-calls* 0)
(define-function ollama-request (body)
  (concat-strings "POST /api/chat HTTP/1.0\r\nHost: 127.0.0.1\r\nContent-Type: application/json\r\nContent-Length: "
		  (long->string (string-length body)) "\r\n\r\n" body))
(tpeg-load "http.g")
(define-function ollama-body (response)		; what follows the headers of a 200, or ()
  (let ((parser (text-parser-for-on <httpreply> response)))
    (and ($reply parser) (<text-parser>-result parser))))
(define-function ollama-exchange (request)	; the server's whole response, or () if it can't be reached
  (try (let ((fd (socket-connect *ollama-port* *ollama-seconds*)))
	 (unwind-protect
	     (let () (socket-send fd request) (socket-receive-all fd))
	   (socket-close fd)))
       (lambda (condition) ())))
(define-function ollama-chat (messages)
  (set *ollama-calls* (+ *ollama-calls* 1))
  (let* ((turns (map (lambda (m) (list 'object (cons "role" (car m)) (cons "content" (cdr m)))) messages))
	 (body (json-write (list 'object (cons "model" *ollama-model*) (cons "messages" turns) (cons "stream" 'false))))
	 (response (ollama-exchange (ollama-request body)))
	 (reply (and response (ollama-body response)))
	 (json (and reply (json-read reply)))
	 (message (and json (json-get (car json) "message")))
	 (content (and (pair? message) (json-get message "content"))))
    (and (string? content) content)))
(define-function ollama-ask (prompt) (ollama-chat (list (cons "user" prompt))))
