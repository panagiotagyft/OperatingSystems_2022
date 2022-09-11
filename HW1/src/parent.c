//.... parent.c ....

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <semaphore.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <fcntl.h>
#include <string.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <time.h>
#include <sys/mman.h>

#define SEM_PERMS (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP)


#define MUTEX_SEM "/mutex"
#define COUNTER_SEM "/counter"
#define MESS_SEM "/mess"

struct Shared_Memory{
	char line[100];
	int requested_line;
};

#define CLIENT_PROGRAM "./client"

int main(int argc,char *argv[]){
	int K, N;
	
	if(argc==1){             // Missing arguments
		printf("Missing arguments...\n");
		return 1;
	}
		
	K=atoi(argv[1]); // K kids
	N=atoi(argv[2]); // N:1 kid -->> loops
	
    void *shared_memory = (void *)0;   
    struct Shared_Memory *shared_mem;
	int SH_id, counter_lines,i, mult;
	sem_t *Mutex_Sem, *Counter_Sem, *Mess_Sem;
	FILE *fp;
	char buf[100], arg1[20];
	mult=K*N;

  	SH_id=shmget((key_t)1234, sizeof(struct Shared_Memory), 0666 | IPC_CREAT);   // Get shared memory segment
	if(SH_id==-1){    // Error message
		fprintf(stderr,"shmget failed\n");
		exit(EXIT_FAILURE);
	}
	
	shared_memory = shmat(SH_id, (void *)0, 0);   
	if (shared_memory == (void *)-1) {  
		fprintf(stderr, "shmat failed\n");
		exit(EXIT_FAILURE);
	}
	printf("Shared memory segment with id %d attached at %p\n", SH_id, shared_memory);   

	shared_mem = (struct Shared_Memory*)shared_memory;    // Create a pointer. The pointer points to the elements of struct 
	
	Mutex_Sem=sem_open(MUTEX_SEM,O_CREAT, SEM_PERMS, 1);  // Create MUTEX_SEM semaphore ( mutual exclusion semaphore )
	if(Mutex_Sem==SEM_FAILED){   // Error message
		fprintf(stderr,"sem_open(3) error1\n");
		exit(EXIT_FAILURE);
	}

	Counter_Sem=sem_open(COUNTER_SEM,O_CREAT, SEM_PERMS, 1);  // Create COUNTER_SEM semaphore ( flag->> if the parent is in the critical section )
	if(Counter_Sem==SEM_FAILED){  // Error message
		fprintf(stderr,"sem_open(3) error2\n");
		exit(EXIT_FAILURE);
	}
	
	Mess_Sem=sem_open(MESS_SEM,O_CREAT, SEM_PERMS, 0);  // Create MESS_SEM semaphore ( flag->> notifies the parent when a child has placed a request in memory)
	if(Mess_Sem==SEM_FAILED){  // Error message
		fprintf(stderr,"sem_open(3) error3\n");
		exit(EXIT_FAILURE);
	}
	
	counter_lines=0;
	if((fp=fopen(argv[3],"r"))==NULL){  // Open file
		perror("fopen saurce-file");  // Error message
		return 1;
	}
	
	while (fgets(buf,100,fp)!=NULL){ counter_lines++; }  // counting of lines 
	rewind(fp);  // Open again the file

    pid_t pids[K];  // Creat K kids
    
	int x,counter=0;
	for(i=0; i< K; i++){  	
		if ((pids[i] = fork()) < 0) { // Error message  
            perror("fork(2) failed");
            exit(EXIT_FAILURE);
        }

        if (pids[i] == 0) {   // I am the child
			sprintf(arg1,"%d",counter_lines);   // Converting integer to string
			if(execl(CLIENT_PROGRAM,CLIENT_PROGRAM,arg1, argv[2],NULL) < 0){  // Call the client process
				perror("execl(2) failed"); // Error message  
				exit(EXIT_FAILURE);
			}
            break;
        }
    
	}

	int j=0;
	mult=K*N;
	while(j<mult){
		
        if(sem_wait(Mess_Sem)==-1){  // Down semapphore -->> -1
			perror("Error sem_wait -->> Mess_Sem");   // Error message  
			return 1;
		}
		
		 // Critical section
		x=shared_mem->requested_line;  // Save line number
        printf("I am the parent.I return the requested line %d\n",x+1); 
		while (fgets(buf,100,fp)!=NULL){
			if(counter==x){     // When the line is found
				strcpy(shared_mem->line,buf);   // Copy the string to the shared memory segment 
				break;
			}
			counter++;  
		}
		counter=0;
		rewind(fp);  // Open the file again
		
		
		if(sem_post(Counter_Sem)==-1){ // Up semapphore -->> +1
			perror("Error sem_post -->> Counter_Sem"); // Error message  
			return 1;
		}
		j++;
	}


    for (i = 0; i < K; i++){   // Wait all chilidren to end 
    	if (waitpid(pids[i], NULL, 0) < 0){ // Error message  
    		perror("waitpid(2) failed");
		}
	}
	
	// Remove -->> semaphores
	if (sem_unlink(COUNTER_SEM) < 0){   
    	perror("sem_unlink(3) failed"); // Error message  
    	exit(EXIT_FAILURE);
	}
    if (sem_unlink(MUTEX_SEM) < 0){
	    perror("sem_unlink(3) failed"); // Error message  
	    exit(EXIT_FAILURE);
	}
	if (sem_unlink(MESS_SEM) < 0){
	   	perror("sem_unlink(3) failed"); // Error message  
	   	exit(EXIT_FAILURE);
	}
        
	if (shmdt(shared_memory) == -1) { // Detach the shared memory segment
		fprintf(stderr, "shmdt failed\n"); // Error message  
		exit(EXIT_FAILURE);
	}
	// Remove -->> shared memory segment
	if (shmctl(SH_id, IPC_RMID, 0) == -1) { // Remove the shared memory segment
		fprintf(stderr, "shmctl(IPC_RMID) failed\n");  // Error message  
		exit(EXIT_FAILURE);
	}
	exit(EXIT_SUCCESS);  
}
