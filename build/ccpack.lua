function Bundlefile1(...)local bh={...}local function r(ak,list)
local bn=false if not list then bn=true list={}end local av=fs.list(ak)
for h,u in ipairs(av)do if fs.isDir(fs.combine(ak,u)
)then r(fs.combine(ak,u),list)else table.insert(list,fs.combine(ak,u)
)end end if bn then return list end end local function run(ak,bp,bq)
local bm=""local y=r(ak)local bo={}for h,az in ipairs(y)
do local b=fs.open(az,'r')local aa=b.readAll()bm=bm.."\nfunction Bundlefile"..h.."(...) "..aa.." end"b.close()
local bg=az:sub(#ak+2)local al=bg:gsub("%.lua$",""):gsub("/",".")
bo[al]="Bundlefile"..h local aq=fs.getName(az):gsub("%.lua$","")
bo[aq]="Bundlefile"..h end for aq,z in pairs(bo)do local be=aq:gsub("([%.%-])","%%%1")
bm=bm:gsub('require%s*%(%s*["\']'..be..'["\']%s*%)',z..'()')
end for aq,z in pairs(bo)do local be=aq:gsub("([%.%-])","%%%1")
bm=bm:gsub('loadfile%s*%(%s*["\']'..be..'%.lua["\']%s*%)',z)
bm=bm:gsub('loadfile%s*%(%s*["\']'..be..'["\']%s*%)',z)
end local aj=bp:gsub("%.lua$","")if bo[aj]then bm=bm.."\n\n"..bo[aj]
.."(...)"end local p=fs.open((bq or"output.lua"),'w')
p.write(bm)p.close()end run(bh[1],bh[2],bh[3])end function Bundlefile2(...)
local bh={...}if bh[1]=="help"then term.clear()term.setCursorPos(1,1)
print("CCPack Usage:")print("  ccpack build")print("    Build project from config.json")
print("")print("  ccpack bundle <folder> <entry> <output>")
print("    Bundle project into single file")print("")
print("  ccpack minify <input> <output>")print("    Minify a lua file")
print("")print("  ccpack config")print("    Edit config.json")
print("")print("  ccpack config create")print("    Create template config.json")
print("")print("  ccpack config help")print("    Show config options")
return end if bh[1]=="config"then if bh[2]=="help"then term.clear()
term.setCursorPos(1,1)print("Config Settings (config.json):")
print("")print("  project_folder")print("    Folder containing source files")
print("")print("  entry_file")print("    Main program file to execute")
print("")print("  output_path")print("    Where to write bundled output")
return end if bh[2]=="create"then if fs.exists("config.json")
then print("Config already exists")write("Overwrite? (y/N) ")
local am,bi=os.pullEvent("key")if bi~=keys.y then print("")
print("Cancelled")return end print("")end local g={project_folder="Project",entry_file="project.lua",output_path="output.lua"}
local i=textutils.serialiseJSON(g)i=i:gsub("{","{\n    ")
:gsub(",",",\n   "):gsub("}","\n}"):gsub(":",": ")local bb=fs.open("config.json",'w')
bb.write(i)bb.close()print("Created config.json")sleep(0.1)
return end shell.run("edit config.json")return end if bh[1]
=="build"then local t=fs.open("config.json","r")local k=t.readAll()
t.close()local g=textutils.unserializeJSON(k)if not fs.isDir(g.project_folder)
then print("Project folder not found")return end print("Project folder:",g.project_folder)
if not fs.exists(g.entry_file)then print("Entry file does not exist")
return end print("Entry point:",g.entry_file)if not g.output_path or g.output_path==""then 
print("Output path not specified")return end print("Output:",g.output_path)
print("Bundling...")local ar=loadfile("src/bundle.lua")
if not ar then print("Bundler not found")return end ar(g.project_folder,g.entry_file,g.output_path)
print("Minifying...")local bf=loadfile("src/minify.lua")
if not bf then print("Minifier not found")return end bf(g.output_path,g.output_path,"50")
print("Project built successfully")return end if bh[1]
=="bundle"then if not bh[2]or not bh[3]or not bh[4]then 
print("Usage: ccpack bundle <folder> <entry> <output>")
return end local ar=loadfile("src/bundle.lua")if not ar then 
print("Bundler not found")return end ar(bh[2],bh[3],bh[4]
)print("Bundled to "..bh[4])return end if bh[1]=="minify"then 
if not bh[2]or not bh[3]then print("Usage: ccpack minify <input> <output>")
return end local bf=loadfile("src/minify.lua")if not bf then 
print("Minifier not found")return end bf(bh[2],bh[3]
,bh[4],bh[5])print("Minified to "..bh[3])return end end 
function Bundlefile3(...)local bh={...}local ak=bh[1]
local output_path=bh[2]local an=bh[3]local c=bh[4]or"export"
local ab={"and","break","do","else","elseif","end","false","for","function","if","in","local","nil","not","or","repeat","return","then","true","until","while"}
local ao={"_G","_VERSION","assert","collectgarbage","error","getmetatable","ipairs","load","loadstring","next","pairs","pcall","print","rawequal","rawget","rawlen","rawset","select","setmetatable","tonumber","tostring","type","xpcall","dofile","getfenv","setfenv","unpack","require","module","loadfile","bit","bit32","coroutine","debug","io","math","os","package","string","table","utf8","fs","http","os","peripheral","rednet","redstone","rs","shell","term","textutils","turtle","vector","window","colors","colours","disk","gps","help","keys","paintutils","parallel","pocket","settings","multishell","commands","read","write","printError","sleep"}
local function ad(ac)for m,aw in ipairs(ab)do if ac==aw then 
return true end end return false end local function n(at)
local bj={}local h=1 local af=#at while h<=af do local char=at:sub(h,h)
if char:match("%s")then h=h+1 elseif at:sub(h,h+1)=="--"then 
if at:sub(h,h+3)=="--[["then local ag=at:find("]]",h+4,true)
h=ag and ag+2 or af+1 else local ag=at:find("\n",h+2,true)
h=ag and ag+1 or af+1 end elseif char=='"'or char=="'"then 
local bl=char local bk=h h=h+1 while h<=af do if at:sub(h,h)
=="\\"then h=h+2 elseif at:sub(h,h)==bl then h=h+1 break else 
h=h+1 end end table.insert(bj,at:sub(bk,h-1))elseif char:match("%d")
then local bk=h while h<=af and at:sub(h,h):match("[%d%.]")
do h=h+1 end table.insert(bj,at:sub(bk,h-1))elseif char:match("[%a_]")
then local bk=h while h<=af and at:sub(h,h):match("[%w_]")
do h=h+1 end local ac=at:sub(bk,h-1)table.insert(bj,ac)
elseif at:sub(h,h+1)==".."or at:sub(h,h+1)=="=="or at:sub(h,h+1)
=="~="or at:sub(h,h+1)=="<="or at:sub(h,h+1)==">="then table.insert(bj,at:sub(h,h+1)
)h=h+2 else table.insert(bj,char)h=h+1 end end return bj 
end local function ae(bj)local l={}local q={}local x={}
local v={}local f=0 local function a(ap)for m,o in ipairs(ao)
do if ap==o then return true end end return false end local 
function d()local ap repeat f=f+1 local e=f ap=""while e>0 do 
local ba=(e-1)%26 ap=string.char(97+ba)..ap e=math.floor((e-1)
/26)end until not ad(ap)and not a(ap)return ap end local h=1 
while h<=#bj do local w=bj[h]if w:match("^[%a_][%w_]*$")
and not ad(w)then q[w]=true end if h>=2 and(bj[h-1]=="."or bj[h-1]
==":")then if w:match("^[%a_][%w_]*$")and not ad(w)then 
x[w]=true end end if w=="local"then h=h+1 if h<=#bj and bj[h]
=="function"then h=h+1 end while h<=#bj do if bj[h]:match("^[%a_][%w_]*$")
and not ad(bj[h])then l[bj[h]]=true h=h+1 if h<=#bj and bj[h]
==","then h=h+1 else break end else break end end elseif w=="function"then 
h=h+1 if h<=#bj and bj[h]:match("^[%a_][%w_]*$")and not ad(bj[h]
)then while h<=#bj and(bj[h]:match("^[%a_][%w_]*$")or bj[h]
=="."or bj[h]==":")do h=h+1 end end if h<=#bj and bj[h]
=="("then h=h+1 while h<=#bj and bj[h]~=")"do if bj[h]
:match("^[%a_][%w_]*$")and not ad(bj[h])then l[bj[h]
]=true end h=h+1 end end elseif w=="for"then h=h+1 while h<=#bj and bj[h]
~="="and bj[h]~="in"do if bj[h]:match("^[%a_][%w_]*$")
and not ad(bj[h])then l[bj[h]]=true end h=h+1 end else h=h+1 
end end local bc={}for ap in pairs(q)do if not l[ap]
and not a(ap)and not x[ap]then bc[ap]=true end end for ap in pairs(l)
do if not x[ap]then v[ap]=d()end end for ap in pairs(bc)
do if not x[ap]then v[ap]=d()end end local ai={}for h=1,#bj do 
if v[bj[h]]then table.insert(ai,v[bj[h]])else table.insert(ai,bj[h]
)end end return ai end local function ay(bj,an)local ai=""
local j=0 if type(an)=="string"then an=tonumber(an)end 
for h=1,#bj do local w=bj[h]local ax=bj[h+1]local ah=bj[h-1]
local bd=false if ax then if w:match("[%w_]$")and ax:match("^[%w_]")
then bd=true elseif w:match("%d$")and ax=="."then bd=false elseif w=="."and ax:match("^%d")
then bd=false elseif w=="."and ax=="."then bd=false elseif w=="="and ax=="="then 
bd=false elseif w=="~"and ax=="="then bd=false elseif w=="<"and ax=="="then 
bd=false elseif w==">"and ax=="="then bd=false end end 
local au=false if an and an>0 and j>an then if w==";"or w=="}"or w==")"or w=="]"or w=="end"or w=="do"or w=="then"or w=="else"then 
au=true elseif ax and(ax=="local"or ax=="function"or ax=="if"or ax=="for"or ax=="while"or ax=="return"or ax=="end")
then au=true end end ai=ai..w j=j+#w if bd then ai=ai.." "j=j+1 
end if au then ai=ai.."\n"j=0 end end return ai end local b=fs.open(ak,'r')
if not b then error("Could not open file: "..ak)end local bj=n(b.readAll()
)b.close()local s=ae(bj)local at=ay(s,tonumber(an))local as=fs.open(output_path,'w')
if not as then error("Could not create output file: "..output_path)
end as.write(at)as.close()print("Minified file written to: "..output_path)
end Bundlefile2(...)