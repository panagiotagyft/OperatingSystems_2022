//.... client.c ....

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

#define MUTEX_SEM "/mutex"
#define COUNTER_SEM "/counter"
#define MESS_SEM "/mess"

struct Shared_Memory{
	char line[100];
	int requested_line;
};


int main(int argc,char *argv[]){
	int no_lines, N;
	void *shared_memory = (void *)0;
	srand((unsigned int)getpid());
	no_lines=atoi(argv[1]);
	N=atoi(argv[2]);
	
	struct Shared_Memory *shared_mem;
	int SH_id, i, random_line;
	sem_t *Mutex_Sem, *Counter_Sem, *Mess_Sem;
	
		
 	SH_id=shmget((key_t)1234, sizeof(struct Shared_Memory), 0666 | IPC_CREAT);  // Get shared memory segment
	if(SH_id==-1){
		fprintf(stderr,"shmget failed\n"); // Error message
		exit(EXIT_FAILURE);
	}
	
	shared_memory = shmat(SH_id, (void *)0, 0);   // Attouch shared memory 
	if (shared_memory == (void *)-1) {
		fprintf(stderr, "shmat failed\n"); // Error message
		exit(EXIT_FAILURE);
	}
	printf("Shared memory segment with id %d attached at %p\n", SH_id, shared_memory);

	shared_mem = (struct Shared_Memory*)shared_memory;  // Create a pointer. The pointer points to the elements of struct 
	
	Mutex_Sem=sem_open(MUTEX_SEM, O_RDWR);     // Use the MUTEX_SEM semaphore
	if(Mutex_Sem==SEM_FAILED){
		fprintf(stderr,"sem_open(3) error\n"); // Error message
		exit(EXIT_FAILURE);
	}
	
	Counter_Sem=sem_open(COUNTER_SEM,O_RDWR);  // Use the COUNTER_SEM semaphore
	if(Counter_Sem==SEM_FAILED){
		fprintf(stderr,"sem_open(3) error\n"); // Error message
		exit(EXIT_FAILURE);
	}
	
	Mess_Sem=sem_open(MESS_SEM, O_RDWR);     // Use the MESS_SEM semaphore
	if(Mess_Sem==SEM_FAILED){
		fprintf(stderr,"sem_open(3) error\n"); // Error message
		exit(EXIT_FAILURE);
	}
	
	i=0;
	int sem_val;
	double start, end,s,counter_t;
	counter_t=0.0;
	while(i < N){
		if(sem_wait(Counter_Sem)==-1){  // Down semapphore -->> +1
			perror("Error sem_wait -->> Counter_Sem"); // Error message
			return 1;
		}
		
		if(sem_wait(Mutex_Sem)==-1){   // Down semapphore -->> +1
			perror("Error sem_wait -->> Mutex_Sem"); // Error message
			return 1;
		}

  		start=((double)clock())/CLOCKS_PER_SEC;		// Start counting time
  		
		random_line=rand()%no_lines;  // Random number
		 
		 // Critical section
		shared_mem->requested_line=random_line;  // Save the random number into the shared memory segment 
		printf("\nI am the child process %d.I want the line: %d\n",getpid(), shared_mem->requested_line+1);
		
		if(sem_post(Mutex_Sem)==-1){  // Up semapphore -->> +1
			perror("Error sem_post -->> Mutex_Sem"); // Error message
			return 1;
		}
		
		if(sem_post(Mess_Sem)==-1){ // Up semapphore -->> +1
			perror("Error sem_post -->> Mess_Sem"); // Error message
			return 1;
		}
        while(1){ // Wait the semaphore  COUNTER_SEM to wake-up
        	if (sem_getvalue (Counter_Sem, &sem_val)== -1){  // Error message
        		perror ("sem_getvalue");
			}
			if (sem_val){  
				end=((double)clock())/CLOCKS_PER_SEC;	 // Stop counting time
				printf("The requested line %d is:  %s\n",shared_mem->requested_line+1,shared_mem->line);
				break;
			}
		}
		counter_t+=end-start;
		i++;
	}
	s=counter_t/N;
	printf("  ------  Child Process %d .Time: %.3f secs  ------\n",getpid(), s);
		
	if (shmdt(shared_memory) == -1) {   // Detach the shared memory segment
		fprintf(stderr, "shmdt failed\n"); // Error message
		exit(EXIT_FAILURE);
	}
	
	exit(EXIT_SUCCESS);
}
