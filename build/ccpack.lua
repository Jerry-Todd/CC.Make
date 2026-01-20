function ce(...)local bu={...}local function as(bv,list)
local aa=false if not list then aa=true list={}end local ah=fs.list(bv)
for af,ae in ipairs(ah)do if fs.isDir(fs.combine(bv,ae)
)then as(fs.combine(bv,ae),list)else table.insert(list,fs.combine(bv,ae)
)end end if aa then return list end end local function run(bv,by,cd)
local bw=""local o=as(bv)local l={}for af,e in ipairs(o)
do local bd=fs.open(e,'r')local y=bd.readAll()bw=bw.."\nfunction Bundlefile"..af.."(...) "..y.." end"bd.close()
local w=e:sub(#bv+2)local t=w:gsub("%.lua$",""):gsub("/",".")
l[t]="Bundlefile"..af local ad=fs.getName(e):gsub("%.lua$","")
l[ad]="Bundlefile"..af l[w]="Bundlefile"..af l[w:gsub("%.lua$","")
]="Bundlefile"..af local ar=fs.getName(e)l[ar]="Bundlefile"..af l[e]
="Bundlefile"..af l[e:gsub("%.lua$","")]="Bundlefile"..af 
end for ad,bi in pairs(l)do local g=ad:gsub("([%.%-%+%*%?%[%]%^%$%(%)%%/])","%%%1")
bw=bw:gsub('require%s*%(%s*["\']'..g..'["\']%s*%)',bi..'()')
end for ad,bi in pairs(l)do local g=ad:gsub("([%.%-%+%*%?%[%]%^%$%(%)%%/])","%%%1")
bw=bw:gsub('loadfile%s*%(%s*["\']'..g..'%.lua["\']%s*%)',bi)
bw=bw:gsub('loadfile%s*%(%s*["\']'..g..'["\']%s*%)',bi)
end local az=by if az:sub(1,#bv)==bv then az=az:sub(#bv+2)
end local bo=l[az]or l[az:gsub("%.lua$","")]or l[fs.getName(az)
]or l[fs.getName(az):gsub("%.lua$","")]if bo then bw=bw.."\n\n"..bo.."(...)"
end local m=fs.open((cd or"output.lua"),'w')m.write(bw)
m.close()end run(bu[1],bu[2],bu[3])end function cc(...)
local bu={...}if bu[1]=="help"then term.clear()term.setCursorPos(1,1)
print("CCPack Usage:")print("  ccpack build")print("    Build project from config.json")
print("")print("  ccpack bundle <folder> <entry> <output>")
print("    Bundle project into single file")print("")
print("  ccpack minify <input> <output>")print("    Minify a lua file")
print("")print("  ccpack config")print("    Edit config.json")
print("")print("  ccpack config create")print("    Create template config.json")
print("")print("  ccpack config help")print("    Show config options")
return end if bu[1]=="config"then if bu[2]=="help"then term.clear()
term.setCursorPos(1,1)print("Config Settings (config.json):")
print("")print("  project_folder")print("    Folder containing source files")
print("")print("  entry_file")print("    Main program file to execute")
print("")print("  output_path")print("    Where to write bundled output")
return end if bu[2]=="create"then if fs.exists("config.json")
then print("Config already exists")write("Overwrite? (y/N) ")
local x,s=os.pullEvent("key")if s~=keys.y then print("")
print("Cancelled")return end print("")end local p={project_folder="Project",entry_file="project.lua",output_path="output.lua"}
local ax=textutils.serialiseJSON(p)ax=ax:gsub("{","{\n    ")
:gsub(",",",\n   "):gsub("}","\n}"):gsub(":",": ")local ag=fs.open("config.json",'w')
ag.write(ax)ag.close()print("Created config.json")sleep(0.1)
return end shell.run("edit config.json")return end if bu[1]
=="build"then local bx=fs.open("config.json","r")local q=bx.readAll()
bx.close()local p=textutils.unserializeJSON(q)if not fs.isDir(p.project_folder)
then print("Project folder not found")return end print("Project folder:",p.project_folder)
if not fs.exists(p.entry_file)then print("Entry file does not exist")
return end print("Entry point:",p.entry_file)if not p.output_path or p.output_path==""then 
print("Output path not specified")return end print("Output:",p.output_path)
print("Bundling...")local h=ce if not h then print("Bundler not found")
return end h(p.project_folder,p.entry_file,p.output_path)
print("Minifying...")local at=ca if not at then print("Minifier not found")
return end at(p.output_path,p.output_path,"50")print("Project built successfully")
return end if bu[1]=="bundle"then if not bu[2]or not bu[3]
or not bu[4]then print("Usage: ccpack bundle <folder> <entry> <output>")
return end local h=ce if not h then print("Bundler not found")
return end h(bu[2],bu[3],bu[4])print("Bundled to "..bu[4]
)return end if bu[1]=="minify"then if not bu[2]or not bu[3]
then print("Usage: ccpack minify <input> <output>")return 
end local at=ca if not at then print("Minifier not found")
return end at(bu[2],bu[3],bu[4],bu[5])print("Minified to "..bu[3]
)return end end function ca(...)local bu={...}local bv=bu[1]
local output_path=bu[2]local i=bu[3]local f=bu[4]or"export"
local aq={"and","break","do","else","elseif","end","false","for","function","if","in","local","nil","not","or","repeat","return","then","true","until","while"}
local bm={"_G","_VERSION","assert","collectgarbage","error","getmetatable","ipairs","load","loadstring","next","pairs","pcall","print","rawequal","rawget","rawlen","rawset","select","setmetatable","tonumber","tostring","type","xpcall","dofile","getfenv","setfenv","unpack","require","module","loadfile","bit","bit32","coroutine","debug","io","math","os","package","string","table","utf8","fs","http","os","peripheral","rednet","redstone","rs","shell","term","textutils","turtle","vector","window","colors","colours","disk","gps","help","keys","paintutils","parallel","pocket","settings","multishell","commands","read","write","printError","sleep"}
local function n(k)for ak,bp in ipairs(aq)do if k==bp then 
return true end end return false end local function c(cf,bz,cb)
local ay=math.floor((bz/cb)*100)local av=30 local z=math.floor((bz/cb)
*av)local ap=string.rep("=",z)..string.rep("-",av-z)
term.clearLine()term.setCursorPos(1,select(2,term.getCursorPos()
))write(cf..": ["..ap.."] "..ay.."%")end local function bl(u)
local ba={}local af=1 local br=#u local bn=0 while af<=br do 
bn=bn+1 if bn%50==0 then c("Tokenizing",af,br)os.queueEvent("yield")
os.pullEvent("yield")end local char=u:sub(af,af)if char:match("%s")
then af=af+1 elseif u:sub(af,af+1)=="--"then if u:sub(af,af+3)
=="--[["then local bq=u:find("]]",af+4,true)af=bq and bq+2 or br+1 else 
local bq=u:find("\n",af+2,true)af=bq and bq+1 or br+1 
end elseif char=='"'or char=="'"then local bh=char local a=af af=af+1 
while af<=br do if u:sub(af,af)=="\\"then af=af+2 elseif u:sub(af,af)
==bh then af=af+1 break else af=af+1 end end table.insert(ba,u:sub(a,af-1)
)elseif char:match("%d")then local a=af while af<=br and u:sub(af,af)
:match("[%d%.]")do af=af+1 end table.insert(ba,u:sub(a,af-1)
)elseif char:match("[%a_]")then local a=af while af<=br and u:sub(af,af)
:match("[%w_]")do af=af+1 end local k=u:sub(a,af-1)table.insert(ba,k)
elseif u:sub(af,af+1)==".."or u:sub(af,af+1)=="=="or u:sub(af,af+1)
=="~="or u:sub(af,af+1)=="<="or u:sub(af,af+1)==">="then 
table.insert(ba,u:sub(af,af+1))af=af+2 else table.insert(ba,char)
af=af+1 end end c("Tokenizing",br,br)print("")return ba 
end local function ao(ba)local bc={}local d={}local am={}
local j={}local bj=0 local function aj(bg)for ak,bf in ipairs(bm)
do if bg==bf then return true end end return false end 
local function be()local bg repeat bj=bj+1 local ab=bj bg=""
while ab>0 do local b=(ab-1)%26 bg=string.char(97+b)
..bg ab=math.floor((ab-1)/26)end until not n(bg)and not aj(bg)
return bg end local af=1 local bn=0 local aw=#ba while af<=aw do 
bn=bn+1 if bn%50==0 then c("Analyzing",af,aw)os.queueEvent("yield")
os.pullEvent("yield")end local r=ba[af]if r:match("^[%a_][%w_]*$")
and not n(r)then d[r]=true end if af>=2 and(ba[af-1]
=="."or ba[af-1]==":")then if r:match("^[%a_][%w_]*$")
and not n(r)then am[r]=true end end if r=="local"then af=af+1 
if af<=#ba and ba[af]=="function"then af=af+1 end while af<=#ba do 
if ba[af]:match("^[%a_][%w_]*$")and not n(ba[af])then bc[ba[af]
]=true af=af+1 if af<=#ba and ba[af]==","then af=af+1 else 
break end else break end end elseif r=="function"then af=af+1 
if af<=#ba and ba[af]:match("^[%a_][%w_]*$")and not n(ba[af]
)then while af<=#ba and(ba[af]:match("^[%a_][%w_]*$")
or ba[af]=="."or ba[af]==":")do af=af+1 end end if af<=#ba and ba[af]
=="("then af=af+1 while af<=#ba and ba[af]~=")"do if ba[af]
:match("^[%a_][%w_]*$")and not n(ba[af])then bc[ba[af]
]=true end af=af+1 end end elseif r=="for"then af=af+1 
while af<=#ba and ba[af]~="="and ba[af]~="in"do if ba[af]
:match("^[%a_][%w_]*$")and not n(ba[af])then bc[ba[af]
]=true end af=af+1 end else af=af+1 end end local bt={}
for bg in pairs(d)do if not bc[bg]and not aj(bg)and not am[bg]
then bt[bg]=true end end for bg in pairs(bc)do if not am[bg]
then j[bg]=be()end end for bg in pairs(bt)do if not am[bg]
then j[bg]=be()end end c("Analyzing",aw,aw)print("")
local au={}for af=1,#ba do if af%50==0 then c("Renaming",af,#ba)
end if j[ba[af]]then table.insert(au,j[ba[af]])else table.insert(au,ba[af]
)end end c("Renaming",#ba,#ba)print("")return au end local 
function bs(ba,i)local au=""local ac=0 if type(i)=="string"then 
i=tonumber(i)end local aw=#ba for af=1,aw do if af%50==0 then 
c("Building",af,aw)end local r=ba[af]local bk=ba[af+1]
local an=ba[af-1]local al=false if bk then if r:match("[%w_]$")
and bk:match("^[%w_]")then al=true elseif r:match("%d$")
and bk=="."then al=false elseif r=="."and bk:match("^%d")
then al=false elseif r=="."and bk=="."then al=false elseif r=="="and bk=="="then 
al=false elseif r=="~"and bk=="="then al=false elseif r=="<"and bk=="="then 
al=false elseif r==">"and bk=="="then al=false end end 
local v=false if i and i>0 and ac>i then if r==";"or r=="}"or r==")"or r=="]"or r=="end"or r=="do"or r=="then"or r=="else"then 
v=true elseif bk and(bk=="local"or bk=="function"or bk=="if"or bk=="for"or bk=="while"or bk=="return"or bk=="end")
then v=true end end au=au..r ac=ac+#r if al then au=au.." "ac=ac+1 
end if v then au=au.."\n"ac=0 end end c("Building",aw,aw)
print("")return au end local bd=fs.open(bv,'r')if not bd then 
error("Could not open file: "..bv)end local ba=bl(bd.readAll()
)bd.close()local bb=ao(ba)local u=bs(bb,tonumber(i))
local ai=fs.open(output_path,'w')if not ai then error("Could not create output file: "..output_path)
end ai.write(u)ai.close()print("Minified file written to: "..output_path)
end cc(...)