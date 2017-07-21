#pragma once
#include <functional>
// An interface to hide the details of how tasks are executed.
namespace animus {
    class task_runner {
    public:
        using task = std::function<void()>;
        virtual void post(const task &t) = 0;
    };
} // namespace animus
