-- Executed with
-- pandoc -f org -t markdown-smart --strip-comments --wrap=none --lua-filter=org.lua index.org -o index.md && sed -i '' -e 's/{width="[0-9]*\\(%\\|px\\)"}//g' -e 's/{#\([a-zA-Z0-9_.-]*\)}/\n---\nid: \1\n---/g' -e 's/\(\.\.\/images\)/https:\/\/vaarnan.com\/img/g' index.md && perl -0777 -i'' -pe 's/::: \{\.MODIFIED \.drawer\}\n\\\[.*?\\\]\n::://gs' index.md

-- function Header(el)
--   print(el)
--   el.attr = pandoc.Attr("", {}, {})
--   return el
-- end

function CodeBlock(el)
  el.attributes['class'] = nil
  return el
end

function Code(el)
  el.attr.classes = {}
  return el
end

local BASE_URL = "http://localhost:8787/alvaro/"

function Link(el)
  if el.target:match("^file:img/") then
    el = pandoc.Image({}, el.target:gsub("^file:img/", BASE_URL))
  else
     -- Make links relative to blog
    el.target = el.target:gsub("^https://vaarnan.com/", "")
  end
  return el
end

function Image(el)
  if el.src:find("^%.%./img/") then
    el.src = "https://vaarnan.com/" .. el.src:sub(4)
  elseif el.src:find("^img/") then
    el.src = "https://vaarnan.com/" .. el.src
  end
  if el.attr.attributes.width then
    el.attr.attributes.width = nil
  end
  if el.attr.attributes.height then
    el.attr.attributes.height = nil
  end
  return el
end

function Span(el)
  for _, class in ipairs(el.classes) do
    if class == "underline" then
      -- If the intention is to discard the underline and keep the text, return the content directly.
      return pandoc.Str(pandoc.utils.stringify(el.content))
    end
  end
  return el
end

function RawBlock(el)
  if el.format == "html" then
    return pandoc.RawBlock("markdown", el.text)
  else
    return el
  end
end
