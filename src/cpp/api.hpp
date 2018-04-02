#pragma once
#include <iostream>
#include <memory>

#include "interface/api.hpp"
#include "interface/async_task.hpp"
#include "interface/event_loop.hpp"
#include "interface/http.hpp"
#include "interface/http_callback.hpp"
#include "interface/thread_launcher.hpp"
#include "nlohmann/json.hpp"

#include "http.hpp"
#include "task_runner.hpp"

namespace animus {
    class api: public animus_generated::api {
    public:
        api(
            const std::shared_ptr<task_runner>& ui_runner,
            const std::shared_ptr<task_runner>& bg_runner,
            const std::shared_ptr<animus_generated::http>& http_client
            );
    private:
        const std::shared_ptr<task_runner> user_interface_dispatcher;
        const std::shared_ptr<task_runner> daemon_dispatcher;
        http http_client;
    };
}
