extern crate neovim_lib;

use neovim_lib::{Neovim, NeovimApi, Session};

enum Messages {
    Add,
    Unknown(String),
}

impl From<String> for Messages {
    fn from(event: String) -> Self {
        match &event[..] {
            "add" => Messages::Add,
            _ => Messages::Unknown(event),
        }
    }
}

fn main() {
    let session = Session::new_parent().unwrap();
    let mut nvim = Neovim::new(session);
    let recv = nvim.session.start_event_loop_channel();

    for (event, values) in recv {
        match Messages::from(event) {
            Messages::Add => {
                let nums = values
                    .iter()
                    .map(|v| v.as_i64().unwrap())
                    .collect::<Vec<i64>>();
                let sum = nums.iter().sum::<i64>();
                nvim.command(&format!("echo \"Result: {}\"", sum.to_string()))
                    .unwrap();
            }

            Messages::Unknown(event) => {
                nvim.command(&format!("echo \"Unknown command: {}\"", event))
                    .unwrap();
            }
        }
    }
}
