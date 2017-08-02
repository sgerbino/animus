#include "event_loop.hpp"

using namespace std;

namespace animus {
    
    task_function::task_function(function<void()> run) : func {std::move(run)} {}
    
    void task_function::execute() {
        func();
    }
    
    event_loop::event_loop(shared_ptr<animus_generated::event_loop> loop) : loop {std::move(loop)} {}
    
    void event_loop::post(const task_runner::task & task) {
        loop->post(make_shared<task_function>(task));
    }
    
    animus_loop::animus_loop(const shared_ptr<animus_generated::thread_launcher> & launcher) : stop(false), done(false) {
        auto task = make_shared<task_function>([this](){
            run();
        });
        launcher->start_thread(string{"daemon_dispatcher"}, task);
    }
    
    animus_loop::~animus_loop() {
        {
            std::lock_guard<std::mutex> task_lock(task_mutex);
            stop = true;
        }
        task_condition_var.notify_one();
        
        std::unique_lock<std::mutex> done_lock(done_mutex);
        done_condition_var.wait(done_lock, [this] () { return done; });
    }
    
    void animus_loop::post(const task_runner::task & task) {
        {
            std::lock_guard<std::mutex> lock(task_mutex);
            queue.emplace(task);
        }
        task_condition_var.notify_one();
    }
    
    void animus_loop::run() {
        while (true) {
            std::unique_lock<std::mutex> lock(task_mutex);
            task_condition_var.wait(lock, [this] {
                return stop == true || !queue.empty();
            });
            if (stop == true) {
                break;
            }
            
            // copy the function off, so we can run it without holding the lock
            auto task = std::move(queue.front());
            queue.pop();
            lock.unlock();
            task();
        }
        
        {
            std::lock_guard<std::mutex> lock(done_mutex);
            done = true;
        }
        done_condition_var.notify_one();
    }
    
}
