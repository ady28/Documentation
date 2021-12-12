package main

import (
	"fmt"
	"runtime"
	"sync"
	"sync/atomic"
	"time"
)

var wg sync.WaitGroup

func main() {

	counter := 0
	counter2 := 0
	//use counter3 with package atomic so needs int64
	var counter3 int64
	const gs = 100

	fmt.Println("CPUs:", runtime.NumCPU())
	fmt.Println("GoRoutines:", runtime.NumGoroutine())

	wg.Add(1)
	//launch f1 in a separate go routine
	go f1()
	f2()

	fmt.Println("CPUs:", runtime.NumCPU())
	fmt.Println("GoRoutines:", runtime.NumGoroutine())

	wg.Wait()

	//the code here will generate a race condition
	//use go run -race file.go to see
	var wg1 sync.WaitGroup
	wg1.Add(gs)

	for i := 0; i < gs; i++ {
		go func() {
			v := counter
			time.Sleep(time.Second)
			runtime.Gosched()
			v++
			counter = v
			wg1.Done()
		}()
	}

	wg1.Wait()
	fmt.Println("GoRoutines:", runtime.NumGoroutine())
	fmt.Println(counter)

	//fix race condition with a mutex
	var mu sync.Mutex

	var wg2 sync.WaitGroup
	wg2.Add(gs)

	for i := 0; i < gs; i++ {
		go func() {
			mu.Lock()
			v := counter2
			runtime.Gosched()
			v++
			counter2 = v
			mu.Unlock()
			wg2.Done()
		}()
	}

	wg2.Wait()
	fmt.Println("GoRoutines:", runtime.NumGoroutine())
	fmt.Println(counter2)

	//using atomic instead of mutex
	var wg3 sync.WaitGroup
	wg3.Add(gs)

	for i := 0; i < gs; i++ {
		go func() {
			atomic.AddInt64(&counter3, 1)
			fmt.Println("Counter3:", atomic.LoadInt64(&counter3))
			runtime.Gosched()
			wg3.Done()
		}()
	}

	wg3.Wait()
	fmt.Println("GoRoutines:", runtime.NumGoroutine())
	fmt.Println(counter3)

	//using channels
	//create a channel
	c := make(chan int)
	//put a value on the channel
	//the run will be blocker until the value is taken off the channel
	//this is why we put in on using a separate routine
	go func() {
		c <- 42
	}()

	fmt.Println(<-c)

	//create a channel that is a buffer
	//this will not block the program until the value is read
	//the 1 means it can buffer one value
	c1 := make(chan int, 1)
	c1 <- 43
	fmt.Println(<-c1)

	c2 := make(chan int)
	//send
	go sc(c2)
	//receive
	rc(c2)
	fmt.Println("Done")

	//range through a channel and close it
	c3 := make(chan int)
	go sc2(c3)
	for v := range c3 {
		fmt.Println(v)
	}
}

func f1() {
	for i := 0; i < 10; i++ {
		fmt.Println("F1:", i)
	}
	wg.Done()
}
func f2() {
	for i := 0; i < 10; i++ {
		fmt.Println("F2:", i)
	}
}

//this function can only put things on the channel
func sc(c chan<- int) {
	c <- 60
}

//this function can only take things from the channel
func rc(c <-chan int) {
	fmt.Println(<-c)
}

//this function can only put things on the channel
func sc2(c chan<- int) {
	for i := 0; i < 40; i++ {
		c <- i
	}
	close(c)
}
