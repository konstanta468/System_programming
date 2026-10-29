#include <stdio.h>
unsigned long create_queue();
void push_queue(unsigned long ,long int);
long int pop_queue(unsigned long);
void print_queue(unsigned long);
void fill_rabdom_queue(unsigned long, long int);
void delete_even_queue(unsigned long);
unsigned long get_list_odd_queue(unsigned long);
unsigned long ending_one_queue(unsigned long);

int main(){
    unsigned long random_q = create_queue();
    fill_rabdom_queue(random_q, 4);

    unsigned long q = create_queue();

    push_queue(q,-1);
    push_queue(q,2);
    push_queue(q,3);
    push_queue(q,4);

    unsigned long odd_q = get_list_odd_queue(q);
    
    print_queue(random_q);

    print_queue(q);
    printf("количество чисел оканчивающихся на 1: %ld\n", ending_one_queue(q));
    printf("список нечётных элементов\n");
    print_queue(odd_q);

    printf("список после удаления чётных чисел\n");
    delete_even_queue(q);
    print_queue(q);   // для -1 2 3 4 ожидается: -1, 3
    return 0;
}
