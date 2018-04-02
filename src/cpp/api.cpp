#include "api.hpp"
#include "event_loop.hpp"
#include "thread_launcher.hpp"
#include "nlohmann/json.hpp"
#include <iostream>

using namespace animus;
using namespace std;

shared_ptr<animus_generated::api> animus_generated::api::create_api(
    const shared_ptr<animus_generated::event_loop> &ui_thread,
    const shared_ptr<animus_generated::http> &http_impl,
    const shared_ptr<animus_generated::thread_launcher> &launcher)
{
    const auto ui_runner = make_shared<animus::event_loop>(ui_thread);
    const auto bg_runner = make_shared<animus::animus_loop>(launcher);
    return make_shared<animus::api>(ui_runner, bg_runner, http_impl);
}

api::api(
    const shared_ptr<task_runner>& ui_runner,
    const shared_ptr<task_runner>& bg_runner,
    const shared_ptr<animus_generated::http>& http_impl) :
        user_interface_dispatcher {ui_runner},
        daemon_dispatcher {bg_runner},
        http_client {http_impl, daemon_dispatcher}
{
}
