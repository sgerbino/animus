#pragma once
#include "interface/http.hpp"
#include "interface/http_callback.hpp"
#include "task_runner.hpp"

namespace animus {
    
    struct http_response {
        bool error;
        uint16_t http_code;
        std::string data;
    };
    
    class http final {
    public:
        http(std::shared_ptr<animus_generated::http> http_impl, const std::shared_ptr<task_runner> & runner);
        void get(const std::string& url, std::function<void(http_response)>);
        void post(const std::string& url, const std::string& data, std::function<void(http_response)>);
        void put(const std::string& url, const std::string& data, std::function<void(http_response)>);
        void patch(const std::string& url, const std::string& data, std::function<void(http_response)>);
        void del(const std::string& url, std::function<void(http_response)>);
    private:
        class request final : public animus_generated::http_callback {
        public:
            request(std::function<void(http_response)> cb, const std::shared_ptr<task_runner> & on_thread);
            virtual void on_network_error();
            virtual void on_success(int16_t http_code, const std::string& data);
            void _cb_with(http_response resp);
        private:
            const std::shared_ptr<task_runner> callback_thread;
            const std::function<void(http_response)> callback;
        };
        const std::shared_ptr<task_runner> callback_thread;
        const std::shared_ptr<animus_generated::http> http_impl;
    };
    
}
