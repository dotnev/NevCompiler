enum TokenType {
	number
	text
	identifier

	declare_var
	double_colon
	mutabel
	use_library
	as_sign
	enum_sign
	param_sign
	type_sign
	if_sign
	else_sign
	match_sign
	return_sign

	equal
	colon
	dot
	comma
	open_scope
	pipe
	equal_to

	greater_than_or_equal_to
	less_than_or_equal_to
	greater_than
	less_than
	not

	binary_operator

	open_round_bracket
	close_round_bracket
	open_curly_bracket
	close_curly_bracket
	open_square_bracket
	close_square_bracket
}
struct Token {
	start int
  end int
	value string
	token_type TokenType
}

struct LexerInfo {
	ignore []rune = "\r\n\t ".runes()

	num_chars []rune = "1234567890".runes()
	num_signs []rune = "_.".runes()

	alphabet []rune = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_".runes()

	str_corners []rune = "'\"".runes()

	dictionary map[string]TokenType = {
		":=": .declare_var
		"::": .double_colon
		"mut": .mutabel
		"use": .use_library
		"as": .as_sign
		"enum": .enum_sign
		"param": .param_sign
		"type": .type_sign
		"if": .if_sign
		"else": .else_sign
		"match": .match_sign
		"return": .return_sign

		"=": .equal
		":": .colon
		".": .dot
		",": .comma
		"=>": .open_scope
		"|>": .pipe

		"==": .equal_to
		">=": .greater_than_or_equal_to
		"<=": .less_than_or_equal_to
		">": .greater_than
		"<": .less_than
		"!": .not

		"%": .binary_operator
		"**": .binary_operator
		"+": .binary_operator
		"-": .binary_operator
		"*": .binary_operator
		"/": .binary_operator

		"(": .open_round_bracket
		")": .close_round_bracket
		"{": .open_curly_bracket
		"}": .close_curly_bracket
		"[": .open_square_bracket
		"]": .close_square_bracket
	}
}

fn tokenize(code string) []Token {
	mut result := []Token{}
	lexer_info := LexerInfo {}
	mut i := 0

	in_code: for {
		println(i)
		if i >= code.len {
			break in_code
		}

		//check if its not impodtant character or no
		for skipable in lexer_info.ignore {
			if skipable == code[i] {
				i += 1
				continue in_code
			}
		}

		// compare with keywords
		for key in lexer_info.dictionary.keys() {
			if i + key.len <= code.len &&
				code[i..i + key.len] == key {
				result << Token {
					start: i
					end: i + key.len
					value: code[i..i + key.len]
					token_type: lexer_info.dictionary[key]
				}
				i += key.len
				continue in_code
			}
		}

		// habdle identifier
		mut ident := ""
		mut id_char_i := 1
		if code[i] in lexer_info.alphabet {
			ident += code[i].ascii_str()
			in_ident: for {
				if i + id_char_i < code.len &&
					(code[i + id_char_i] in lexer_info.alphabet ||
					code[i + id_char_i] in lexer_info.num_chars) {
					ident += code[i + id_char_i].ascii_str()
					id_char_i++
				} else { break in_ident }
			}
			result << Token {
				start: i
				end: i + id_char_i
				value: ident
				token_type: .identifier
			}
			i += id_char_i
			continue in_code
		}

		// save number
		mut number := ""
		mut num_char_index := 1
		if code[i] in lexer_info.num_chars {
			number += code[i].ascii_str()
			in_number: for {
				if i + num_char_index < code.len &&
					(code[i + num_char_index] in lexer_info.num_chars ||
					code[i + num_char_index] in lexer_info.num_signs) {
					number += code[i + num_char_index].ascii_str()
					num_char_index++
				} else { break in_number}
			}
			result << Token {
				start: i
				end: i + num_char_index
				value: number
				token_type: .number
			}
			i += num_char_index
			continue in_code
		}


		mut text := ""
		mut txt_char_i := 1
		mut str_corner := '"'
		if code[i] in lexer_info.str_corners {
			str_corner = code[i].ascii_str()
			in_text: for {
				if i + txt_char_i < code.len &&
					code[i + txt_char_i].ascii_str() != str_corner {
					text += code[i + txt_char_i].ascii_str()
					txt_char_i++
				} else {
					break in_text
				}
			}
			result << Token {
				start: i
				end: i + txt_char_i
				value: text
				token_type: .text
			}
			i += txt_char_i + 1
			continue in_code
		}
	}
	return result
}
