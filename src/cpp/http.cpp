#include "http.hpp"

using namespace std;
using namespace animus;

namespace animus {
    
    http::http(shared_ptr<animus_generated::http> http_impl, const shared_ptr<task_runner> & cb_thread)
    : callback_thread {std::move(cb_thread)}
    , http_impl {std::move(http_impl)} {}
    
    void
    http::get(const string& url, function<void(http_response)> callback) {
        http_impl->get(url, make_shared<http::request>(std::move(callback), callback_thread) );
    }
    
    http::request::request(function<void(http_response)> cb, const shared_ptr<task_runner> & on_thread)
    : callback_thread {on_thread}
    , callback {std::move(cb)} {}
    
    void
    http::request::on_network_error() {
        http_response resp;
        resp.error = true;
        _cb_with(std::move(resp));
    }
    
    void
    http::request::on_success(int16_t http_code, const string& data) {
        http_response resp;
        resp.error = false;
        resp.http_code = http_code;
        resp.data = data;
        _cb_with(std::move(resp));
    }
    
    void
    http::request::_cb_with(http_response resp) {
        auto callback = this->callback;
        auto shared_resp = make_shared<http_response>(std::move(resp));
        callback_thread->post([callback, shared_resp] () {
            callback(std::move(*shared_resp));
        });
    }
    
}
