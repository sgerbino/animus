#include "api.hpp"
#include "event_loop.hpp"
#include "thread_launcher.hpp"
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
    http_client.get("https://jsonplaceholder.typicode.com/posts", [ui = user_interface_dispatcher] (http_response resp) {
        if (resp.error) {
            return;
        }
        
        std::cout << resp.http_code << std::endl;
        std::cout << resp.data << std::endl;
        std::cout << std::this_thread::get_id() << " bg thread" << std::endl;
        ui->post([](){ std::cout << std::this_thread::get_id() << " ui thread" << std::endl; });
    });
}
