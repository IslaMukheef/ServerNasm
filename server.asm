section .data
  sockaddr_in:
        dw 2       ; address family of AF_INET
        dw 0x901f  ; port 8080 in big-endian
        dd 0        ; 4 bytes value that represent the IP address
  msg db 128 dup(0)   ; buffer for client message
 
section .bss  ; will hold a reserved space for file descriptors later on 
  socket_fd resq 1; space for the socket file descriptor
  client_fd resq 1; space for the client socket

section .text ; holds our code
global _start  ; where our program gonna start
_start:
  
  ;creating a socket
    mov rax, 41 ; sys call for socket
    mov rdi, 2 ; 2 for AF_INET TCP
    mov rsi, 1 ; 1 for SOCK_STREAM
    xor rdx , rdx ; set rdx to 0 for default protocal
    syscall
    mov  [socket_fd], rax; move the socekt to socket_fd
        
    ; bind
    mov rax, 49 ; sys call for bind
    mov rdi , [socket_fd]; move the socket fd to rdi
    lea rsi, [sockaddr_in] ; pointer to sockaddr_in
    mov rdx, 16             ; size of sockaddr_in
    syscall
    
    ; create listen
    mov rax, 50 ; sys call for listen
    mov rdi , [socket_fd]
    mov rsi , 5 ; backlog 
    syscall
    
    ; create accept
    mov rax, 43
    mov rdi, [socket_fd] ; sockfd
    xor rsi , rsi ; sockaddr
    xor rdx, rdx ; addrlen
    syscall
    mov [client_fd], rax;
    
    ; receive message 
    mov rax, 45 ; recv from sys call
    mov rdi, [client_fd] ; use client fd
    lea rsi , [msg] ; buffer for the message
    mov rdx , 128       ; message length
    syscall
    ;null terminate
    mov rcx, rax
    mov byte [msg + rcx], 0
    
    
    ;print the message
     mov rax, 1 ; sys call for stdout
     mov rdi, 1; stdout 
     lea rsi, [msg] ; buffer
     mov rdx , rcx; length of message
     syscall
     
     
     ;close sockets
    ;client socket
    mov rax, 3 ; sys call for close
    mov rdi, [client_fd]; client fd
    syscall
    ;our socket
    mov rax, 3 ; sys call for close
    mov rdi, [socket_fd]; server fd socket
    syscall
    
    ; exit
    mov rax , 60; sys call for exit
    mov rdi , 0 ; for no error
    syscall
