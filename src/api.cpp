#include "api.hpp"
#include <memory>
#include "json.hpp"
#include <iostream>

struct api_impl: Api {
    bool do_something() {
        return true;
    }
    
    bool do_something_else() {
        return true;
    }
    
    bool do_great_things() {
        return true;
    }
};


std::shared_ptr<Api> Api::get() {
    return std::make_shared<api_impl>();
}

using json = nlohmann::json;

int main(int argc, char **argv)
{
    json j = {
        {"pi", 3.141}
    };
    j["three"] = 3;
    std::cout << j.dump(4) << std::endl;
    return 0;
}
