class_name L10nTranslation
extends Translation
## The TranslationServer hook for L10n: every Label, Button, tooltip, RichTextLabel, OptionButton item and Label3D
## asks this for its text. Returns "" (= keep the source) when L10n has nothing better.


func _get_message(src_message: StringName, _context: StringName = &"") -> StringName:
	var s := String(src_message)
	var r := L10n.translate(s)
	return StringName(r) if r != s else &""


func _get_plural_message(src_message: StringName, src_plural_message: StringName, n: int, _context: StringName = &"") -> StringName:
	return _get_message(src_message if n == 1 else src_plural_message)
