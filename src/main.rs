extern crate neovim_lib;

use neovim_lib::{Neovim, NeovimApi, Session};
use std::fs::File;
use std::io::Write;

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
                print!("{}", sum);

                let mut file = File::create("test.txt").unwrap();
                file.write_all(b"hoge").unwrap();
                // nvim.command(&format!("echo \"Result: {}\"", sum.to_string()))
                //     .unwrap();
            }

            Messages::Unknown(event) => {
                nvim.command(&format!("echo \"Unknown command: {}\"", event))
                    .unwrap();
            }
        }
    }
}
