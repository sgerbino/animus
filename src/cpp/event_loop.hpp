#pragma once
#include <thread>
#include <queue>
#include <atomic>

#include "interface/event_loop.hpp"
#include "interface/async_task.hpp"
#include "interface/thread_launcher.hpp"

#include "task_runner.hpp"

namespace animus {
    
    // a helper class to turn the `async_task` api into a std::function based one
    class task_function final : public animus_generated::async_task {
    public:
        task_function(std::function<void()> run);
        virtual void execute() override;
    private:
        std::function<void()> func;
    };
    
    // an interface wrapper on top of the platform event loops
    class event_loop final : public task_runner {
    public:
        event_loop(std::shared_ptr<animus_generated::event_loop> loop);
        virtual void post(const task_runner::task & task) override;
    private:
        const std::shared_ptr<animus_generated::event_loop> loop;
    };
    
    // A implementation of implemented in pure c++.
    class animus_loop final : public task_runner {
    public:
        animus_loop(const std::shared_ptr<animus_generated::thread_launcher> & launcher);
        ~animus_loop();
        virtual void post(const task_runner::task & task) override;
        
    private:
        // the actual run loop runs here
        void run();
        std::mutex task_mutex;
        std::condition_variable task_condition_var;
        bool stop;
        std::queue<task_runner::task> queue;
        
        bool done;
        std::mutex done_mutex;
        std::condition_variable done_condition_var;
    };
    
}
