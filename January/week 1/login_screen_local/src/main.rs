use std::{env, io};
use std::io::Write;
use std::process;
use argonautica::Hasher;
use reqwest::Response;
use rpassword::read_password;
use serde::{Deserialize, Serialize};
//use serde_json::{Result};

#[derive(Serialize, Deserialize)]
struct User {
	id: String,
	email: String,
	password: String,
}

#[derive(Debug)]
enum LoginResult {
	AlreadyQuited(bool),
	AuthCode(String),
	Error(String),
	Helped(bool),
	SignedUp(bool),
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

fn abort() -> Result<LoginResult, LoginResult>{
	println!("AHHHHHHHHH");
	process::exit(0);
	let x: Result<LoginResult, LoginResult> = Ok(LoginResult::AlreadyQuited(true));
	x //since the compiler will complain...
}

fn help() -> Result<LoginResult, LoginResult> {
	println!("You need help? I don't think I'm the right person to ask. Try calling someone on your phone.");
	abort();
	let x: Result<LoginResult, LoginResult> = Ok(LoginResult::Helped(true));
	x //since the compiler will complain...
}

fn signin() -> Result<LoginResult, LoginResult> {
	println!("You want to sign in? Well, not today.");
	abort();
	let x: Result<LoginResult, LoginResult> = Ok(LoginResult::AuthCode(String::from("some_auth_code")));
	x //since the compiler will complain...
}

async fn send_json(user_json: serde_json::Result<String>) -> reqwest::Result<Response> {
	let client = reqwest::Client::new();
	let server_url = env::var("SERVER_URL").expect("SERVER_URL must be set");

	let res = client.post(&server_url)
		.body("hi!")
		.send()
		.await?;

	println!("{:?}", &user_json);
	println!("{:?}", &res);

	let x: reqwest::Result<Response> = Ok(res);
	x
}

async fn signup() -> Result<LoginResult, LoginResult> {
	loop {
		print!("\x1B[2J");
		let mut id = String::new();
		let mut email = String::new();

		print!("Please enter your ID: ");
		io::stdout().flush().unwrap();
		io::stdin().read_line(&mut id)
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
			let user = User {
				id: id,
				email: email,
				password: hash(password)	
			};
			let user_json = serde_json::to_string(&user);
			println!("{:?}", user_json);
			send_json(user_json).await;
			break;
		}
	}
	let x: Result<LoginResult, LoginResult> = Ok(LoginResult::SignedUp(true));
	x
}

async fn login_screen() -> io::Result<()>{
	let mut not_authenticated = true;
	while not_authenticated {
		print!("\x1B[2J");
		print!("Hello! Would you like to (R)egister or (S)ign in? ");
		io::stdout().flush().unwrap();
		let mut input = String::new();
		io::stdin().read_line(&mut input)
				.expect("Failed to read line");
		match input.trim().to_uppercase().as_str() {
				"ABORT" | "EXIT" | "Q" | "QUIT" => abort(),
				"HELP" | "H" => help(),
				"SIGN UP" | "SIGNUP" | "REGISTER" | "R" => signup().await,
				"SIGN IN" | "SIGNIN" | "LOGIN" | "LOG IN" | "S" => signin(),
				_  => continue,
		};
		if 1+1==2 { //will be an authentication code or something like that later on...
			not_authenticated = false;
		}
	}
	Ok(())
}

/**
fn do_something(){

}
**/

async fn main() -> io::Result<()> {
	login_screen().await
}
