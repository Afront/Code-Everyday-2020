use std::{env, io};
use std::io::Write;
use std::process;
use argonautica::Hasher;
use reqwest::Response;
use rpassword::read_password;
use serde::{Deserialize, Serialize};
//use serde_json::{Result};

#[derive(Debug)]
enum Error {
	Login(LoginResult),
	Reqwest(reqwest::Error),
	SerdeJSON(serde_json::error::Error),
}

impl std::convert::From<reqwest::Error> for Error {
	fn from(err: reqwest::Error) -> Error {
		Error::Reqwest(err)
	}
}

impl std::convert::From<serde_json::Error> for Error {
	fn from(err: serde_json::Error) -> Error {
		Error::SerdeJSON(err)
	}
}


#[derive(Serialize, Deserialize)]
struct NewUser {
	username: String,
	email: String,
	password: String,
}

#[derive(Serialize, Deserialize)]
struct OldUser {
	id: String,
	password: String,
}


#[derive(Debug)]
enum LoginResult {
	AuthCode(String),
	Helped,
	Quit,
	SignedUp,
}


fn hash(password: String) -> String {
	let mut hasher = Hasher::default();
	let hash = hasher
		.with_password(password)
		.with_salt("this will not be the actual salt")
		.with_secret_key("this will not be the secret key, just a placeholder")
		.hash()
		.unwrap();
	println!("{}", &hash);
	hash
}

fn abort() -> Result<LoginResult, Error>{
	println!("See you next time!");
	Ok(LoginResult::Quit)
}

fn help() -> Result<LoginResult, Error> {
	let something_wrong_happened = false;
	println!("You need help? I don't think I'm the right person to ask. Try calling someone on your phone.");

	match something_wrong_happened {
		true => Ok(LoginResult::Helped),
		false => Err(Error::Login(LoginResult::Helped)),
	}
}

async fn signin() -> Result<LoginResult, Error> {
	loop {
		print!("\x1B[2J");
		let mut id = String::new();

		print!("Please enter your username or your email: ");
		io::stdout().flush().unwrap();
		io::stdin().read_line(&mut id)
				.expect("Failed to read line");

		print!("Please enter your password: ");
		io::stdout().flush().unwrap();
		
		let user = OldUser {
			id: id,
			password: hash(read_password().unwrap())	
		};
		let user_json = serde_json::to_string(&user)?;
		println!("{:?}", user_json);
		send_json(user_json).await?;
	}
	Ok(LoginResult::AuthCode(String::from("some_auth_code")))
}

async fn send_json(user_json: String) -> Result<Response, Error> {
	let client = reqwest::Client::new();
	let server_url = env::var("SERVER_URL").expect("SERVER_URL must be set");

	let res = client.post(&server_url)
		.body("hi!")
		.send()
		.await?;

	println!("{:?}", &user_json);
	println!("{:?}", &res);

	Ok(res)
}

async fn signup() -> Result<LoginResult, Error> {
	loop {
		print!("\x1B[2J");
		let mut username = String::new();
		let mut email = String::new();

		print!("Please enter your username: ");
		io::stdout().flush().unwrap();
		io::stdin().read_line(&mut username)
				.expect("Failed to read line");

		print!("Please enter your email: ");
		io::stdout().flush().unwrap();
		io::stdin().read_line(&mut email)
				.expect("Failed to read line");

		print!("Please enter your password: ");
		io::stdout().flush().unwrap();
		let password = read_password().unwrap();
		
		print!("Please enter your password again: ");
		io::stdout().flush().unwrap();
		if password == read_password().unwrap() {
			let user = NewUser {
				username: username,
				email: email,
				password: hash(password)	
			};
			let user_json = serde_json::to_string(&user)?;
			println!("{:?}", user_json);
			send_json(user_json).await?;
			return Ok(LoginResult::SignedUp)
		}
	}
}

async fn login_screen() -> Result<LoginResult, Error>{
	loop {
		print!("\x1B[2J");
		print!("Hello! Would you like to (R)egister or (S)ign in? ");
		io::stdout().flush().unwrap();
		let mut input = String::new();
		io::stdin().read_line(&mut input)
				.expect("Failed to read line");
		match match input.trim().to_uppercase().as_str() {
				"ABORT" | "EXIT" | "Q" | "QUIT" => abort(),
				"HELP" | "H" => help(),
				"SIGN UP" | "SIGNUP" | "REGISTER" | "R" => signup().await,
				"SIGN IN" | "SIGNIN" | "LOGIN" | "LOG IN" | "S" => signin().await,
				_  => continue,
		} {
			Ok(LoginResult::Quit) => process::exit(0),
			Ok(LoginResult::Helped) => continue,
			Ok(LoginResult::SignedUp) => continue,
			Ok(LoginResult::AuthCode(auth_code)) => return Ok(LoginResult::AuthCode(auth_code)),
			Err(err) => println!("{:?}", err),
		};
	}
}

/**
fn do_something(){

}
**/

#[tokio::main]
async fn main() -> Result<(),Error> {
	match login_screen().await {
		Ok(_) => (),
		Err(_) => (),
	}

	Ok(())
}
