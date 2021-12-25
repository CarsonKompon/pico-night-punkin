pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--week 7 source code
--top secret hush hush

function _init()
	poke(0x5f2d,1)
	seed = flr(rnd(8000))*4
	baseseed = seed
	songid = 5
	cartdata("ckcw_fnfp8")
	menuitem(1,"back to title",function() dset(60,1) load("fnf-select.p8") end)
	function toggle_downscroll()
		if downscroll == 0 then
			downscroll = 1
			menuitem(2,"downscroll: on",toggle_downscroll)
		else
			downscroll = 0
			menuitem(2,"downscroll: off",toggle_downscroll)
		end
		dset(50,downscroll)
	end
	downscroll = dget(50)
	if downscroll == 0 then
		menuitem(2,"downscroll: off",toggle_downscroll)
	else
		menuitem(2,"downscroll: on",toggle_downscroll)
	end
	difficulty = dget(55)
	local _potseed = dget(54)
	if difficulty == 2 and _potseed ~= 0 then
		seed = _potseed
		baseseed = seed
	end
	fadein = 15
	fadeout = -1
	game_init() --its that easy???
	synctime = 350
end

function _update60()
	if(fadein > 0) fadein-=0.5
	if fadeout > 0 then
		fadeout-=0.5
		if fadeout == 0 then
			if(score > dget(songid) and hp > 0) dset(songid,score)
			dset(60,1)
			load("fnf-select.p8")
		end
	end
	game_update() --yes!!!!
	
	--if(stat(26) > synctime) synctime = stat(26)
end

function _draw()
	game_draw() --fuck no!!!!
	if(fadein > 0) fadeall(ceil(fadein))
	if(fadeout > -1) fadeall(15-ceil(fadeout))
	--print(synctime,0,0,0)
end
-->8
--game controller
function game_init()
	camx = 0
	camy = -10
	camxto = 0
	camyto = 0
	camlerp = 0.0325
	laststep = 0
	step = 0
	score = 0
	hp = 250
	maxhp = 500
	press = {false,false,false,false}
	currentpattern=-1
	
	leftmap = {}
	rightmap = {}
	lastmap = -1
	if difficulty == 0 then
		init_beatmap()
	else
		init_beatmap_hard()
	end
	
	arrows_init()
	parts_init()
	popups_init()
	
	chars_init()
	
	move_cam(0,-2)
end

function game_update()
	laststep = step
	step+=1
	--step = stat(26) + (stat(24)*  350)
	--if(stat(26)+(stat(24)*350) >= 350) step-=1
	if(step < 0) move_cam(0,-4)
	
	if stat(24) ~= currentpattern then
		currentpattern = stat(24)
		step = ((((32*currentpattern)+1)/32)*(synctime/2))
	end
	
	--save seed to clipboard
	if difficulty == 2 and btnp(🅾️,1) then
		printh(baseseed,"@clip")
	end
	
	if abs(step-laststep) < 10 then
		--left side
		if #leftmap > 0 then
			if step >= (((leftmap[1][1]+1)/32)*((synctime-1)/2))-(notetime) then
				if #leftmap[1] > 3 then
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], leftmap[1][3], leftmap[1][4])
				elseif #leftmap[1] > 2 then
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], leftmap[1][3], false)
				else
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], 0, false)
				end
				deli(leftmap,1)
			end
		end
		
		--right side
		if #rightmap > 0 then
			if step >= (((rightmap[1][1]+1)/32)*(synctime/2))-(notetime) then
				if #rightmap[1] > 2 then
					spawn_arrow(rightmap[1][1],1, rightmap[1][2], rightmap[1][3])
				else
					spawn_arrow(rightmap[1][1],1, rightmap[1][2], 0)
				end
				deli(rightmap,1)
			end
		end
	end
	
	if hp > 0 then
		chars_update()
		arrows_update()
		parts_update()
		popups_update()
	end
	
	--dead
	if hp <= 0 then
		dset(62,chars[2].x-camx)
		dset(63,chars[2].y-camy)
		dset(61,songid)
		load("fnf-gameover.p8")
	end
	
	if stat(24)==-1 and fadeout == -1 then
		fadeout = 15
	end
	
	--center camera on duet (320)
	local _duetstart = ((320+1)/32)*175
	local _duetlength = ((30+1)/32)*175
	if step >= _duetstart and step < _duetstart+_duetlength then
		move_cam(4,-2)
	end
	--center camera on duet (384)
	local _duetstart = ((384+1)/32)*175
	local _duetlength = ((30+1)/32)*175
	if step >= _duetstart and step < _duetstart+_duetlength then
		move_cam(4,-2)
	end
	
	camx = lerp(camx,camxto,camlerp)
	camy = lerp(camy,camyto,camlerp)
	camera(camx,camy)
	
end

--move camera--
function move_cam(_x,_y,_lerp)
	_lerp = _lerp or camlerp
	camxto = _x
	camyto = _y
	camlerp = _lerp
end

-- get inputs ⬅️⬇️⬆️➡️ --
function get_inputs()
	lastpress = {press[1],press[2],press[3],press[4]}
	press = {false,false,false,false}
	if(btn(⬅️) or stat(28,7)) press[1] = true
	if(btn(⬇️) or stat(28,9)) press[2] = true
	if(btn(⬆️) or stat(28,13) or btn(❎)) press[3] = true
	if(btn(➡️) or stat(28,14) or btn(🅾️)) press[4] = true
end

function game_draw()
	cls(9)
	pal()
	local lx = camx/2
	local ly = camy/2
	
	--rectfill(lx-10,ly+75,lx+138,ly+130,13)
	--rectfill(lx-10,ly+64,lx+4,ly+75,13)
	
	fillp(█)
	circfill(lx+63,ly+481,400,2)
	fillp(▒)
	circfill(lx+63,ly+485,400,4)
	fillp(█)
	circfill(lx+63,ly+485+4,400,4)
	color(15)
	line(lx+44,ly+38,lx+72,ly+44)
	line(lx+112,ly+36,lx+138,ly+48)
	--line(lx-10,ly+46,lx+16,ly+32)
	for i=0,48 do
		line(lx-10,ly-i+44,lx+16,ly-i+36)
		line(lx+16,ly-i+36,lx+32,ly-i+27)
		line(lx+32,ly-i+27,lx+44,ly-i+38)
		line(lx+44,ly-i+38,lx+75,ly-i+27)
		line(lx+75,ly-i+27,lx+83,ly-i+20)
		line(lx+83,ly-i+20,lx+96,ly-i+28)
		line(lx+96,ly-i+28,lx+112,ly-i+36)
		line(lx+112,ly-i+36,lx+138,ly-i+38)
	end
	
	color(7)
	--print(step, 0, 0)
	--print(score,0, 8)
	--print(step-laststep,32,0)
	
	
	if hp > 0 then
		chars_draw()
		local _nh = 128-noteheight
		
		--left side
		if downscroll == 0 then
			sspr(56,46,11,12,camx+4+(14*0),camy+_nh,11,12,true)
			sspr(67,46,12,11,camx+4+(14*1),camy+_nh,12,11,false,true)
			sspr(67,46,12,11,camx+4+(14*2),camy+_nh,12,11)
			sspr(56,46,11,12,camx+4+(14*3),camy+_nh,11,12)
		else
			sspr(56,46,11,12,camx+4+(14*0),camy+128-12-_nh,11,12,true)
			sspr(67,46,12,11,camx+4+(14*1),camy+128-12-_nh,12,11,false,true)
			sspr(67,46,12,11,camx+4+(14*2),camy+128-12-_nh,12,11)
			sspr(56,46,11,12,camx+4+(14*3),camy+128-12-_nh,11,12)
		end
		
		--right side
		if downscroll == 0 then
			if(press[1]) arrow_color(0)
			sspr(56,46,11,12,camx+113-14*3,camy+_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(67,46,12,11,camx+113-14*2,camy+_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(67,46,12,11,camx+113-14*1,camy+_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(56,46,11,12,camx+113-14*0,camy+_nh,11,12)
			pal()
		else
			if(press[1]) arrow_color(0)
			sspr(56,46,11,12,camx+113-14*3,camy+128-12-_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(67,46,12,11,camx+113-14*2,camy+128-12-_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(67,46,12,11,camx+113-14*1,camy+128-12-_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(56,46,11,12,camx+113-14*0,camy+128-12-_nh,11,12)
			pal()
		end
		
		--particles
		parts_draw()
		
		--popups
		popups_draw()
		
		--arrows
		if downscroll == 0 then
			arrows_draw()
		else
			arrows_draw_downscroll()
		end
		
		--health bar
		if downscroll == 0 then
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+127-8,camx+63-42+84,camy+127-2,3)
			rectfill(camx+63-42+1,camy+127-7,camx+63-42+84-1,camy+127-3,11)
			rectfill(camx+63-42,camy+127-8,_xx,camy+127-2,2)
			rectfill(camx+63-42+1,camy+127-7,_xx,camy+127-3,8)
			palt(11,true)
			palt(0,false)
			sspr(115,0,13,9,_xx+3,camy+127-9)
			sspr(115,9,13,9,_xx-3-11,camy+127-10)
		else
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+128-(127-8),camx+63-42+84,camy+128-(127-2),3)
			rectfill(camx+63-42+1,camy+128-(127-7),camx+63-42+84-1,camy+128-(127-3),11)
			rectfill(camx+63-42,camy+128-(127-8),_xx,camy+128-(127-2),2)
			rectfill(camx+63-42+1,camy+128-(127-7),_xx,camy+128-(127-3),8)
			palt(11,true)
			palt(0,false)
			sspr(115,0,13,9,_xx+3,camy+128-9-(127-9))
			sspr(115,9,13,9,_xx-3-11,camy+128-10-(127-10))
		end
		
		--score
		if downscroll == 0 then
			print(tostr(score),camx+64-#tostr(score)*2,camy+4,0)
		else
			print(tostr(score),camx+64-#tostr(score)*2,camy+128-8,7)
		end
		
	else
		--dead
		rectfill(camx,camy,camx+128,camy+128,0)
		palt(0,false)
		palt(3,true)
		fade(7)
		sspr(28,30,27,27,chars[2].x-flr(27/2),chars[2].y-27)
		pal()
	end
	pal()
end

function dir_to_ang(_dir)
	if(_dir == 0) return 180
	if(_dir == 1) return 90
	if(_dir == 2) return 270
	return 0
end

--linear interpolation
function lerp(pos,tar,perc)
 return pos+((tar-pos)*perc)
end

-- fade to black
local fadetable0={
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
{2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
{3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
{4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
{5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
{6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
{7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
{8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
{9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
{10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
{11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
{12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
{13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
{14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
{15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

function fade(i)
	for c=0,15 do
		if flr(i+1)>=16 then
			pal(c,0)
		else
			pal(c,fadetable0[c+1][flr(i+1)])
		end
	end
end

function fadeall(i)
	for c=0,15 do
		if flr(i+1)>=16 then
			pal(c,0,1)
		else
			pal(c,fadetable0[c+1][flr(i+1)],1)
		end
	end
end

function spr_r(sx,sy,x,y,a,w,h)
 sw=(w or 8)
 sh=(h or 8)
 x0=flr(0.5*sw)
 y0=flr(0.5*sh)
 a=a/360
 sa=sin(a)
 ca=cos(a)
 for ix=0,sw-1 do
  for iy=0,sh-1 do
   dx=ix-x0
   dy=iy-y0
   xx=flr(dx*ca-dy*sa+x0)
   yy=flr(dx*sa+dy*ca+y0)
   if (xx>=0 and xx<sw and yy>=0 and yy<=sh) then
    pset(x+ix,y+iy,sget(sx+xx,sy+yy))
   end
  end
 end
end

--choose random array
function choose(t)
	return t[flr(rnd(#t))+1]
end
-->8
--beatmap
function init_beatmap_hard()
	
	--tankman
	map_add(leftmap,0,"32,3:34,3:36,0,2:38,3:40,2,2:42,3:44,0,4")
	map_add(leftmap,0,"48,3:49,2:50,3:51,1:52,0:53,1:54,0,2:56,1,4:60,3,4")
	map_add(leftmap,0,"64,3:66,3:68,0,2:70,3:72,2,2:74,3:76,1,4:80,3:82,2:84,1:86,0:88,3,4:92,2,0,true")
	
	--boyfriend
	map_add(rightmap,64,"32,3:34,3:36,0,2:38,3:40,2,2:42,3:44,0,4")
	map_add(rightmap,64,"48,3:49,2:50,3:51,1:52,0:53,1:54,0,2:56,1,4:60,3,4")
	map_add(rightmap,64,"64,3:66,3:68,0,2:70,3:72,2,2:74,3:76,1,4:80,3:82,2:84,1:86,0:88,3,4:92,2,4")
	
	--tankman
	map_add(leftmap,0,"160,3:162,1:164,0:166,1:168,0:169,1:170,3:171,1:172,0,2:174,1:176,3,2:178,1:180,3,2:182,0:184,2:186,3:188,0:190,3") 
	map_add(leftmap,0,"192,3:194,3:195,2:196,3:198,2:199,1:200,2:202,1:203,0:204,1:206,0:208,1,2:210,2,2:212,3,2:214,0,2:216,1,2:218,0:219,1:220,3,2:222,0") 
	
	--boyfriend
	map_add(rightmap,64,"160,3:162,1:164,0:166,1:168,0:169,1:170,3:171,1:172,0,2:174,1:176,3,2:178,1:180,3,2:182,0:184,2:186,3:188,0:190,3") 
	map_add(rightmap,64,"192,3:194,3:195,2:196,3:198,2:199,1:200,2:202,1:203,0:204,1:206,0:208,1,2:210,2,2:212,3,2:214,0,2:216,1,2:218,0:219,1:220,3,2:222,0") 
	
	--tankman
	map_add(leftmap,0,"288,1:289,0:290,1:291,2:292,3:294,1:295,0:296,1:297,2:298,3:300,1:301,0:302,1:303,2:304,3:306,1:307,0:308,1:309,2:310,3,2:312,0,4:316,1,2:318,3,2")
	map_add(leftmap,0,"320,1,4:324,2,4:328,3,4:332,1,4:336,0,4:340,1,4:344,3,4:348,3,4")
	
	--boyfriend
	map_add(rightmap,0,"320,1:321,0:322,1:323,2:324,3:326,1:327,0:328,1:329,2:330,3:332,1:333,0:334,1:335,2:336,3:338,1:339,0:340,1:341,2:342,3,2:344,0,4:348,1,2:350,3,2")
	
	--tankman
	map_add(leftmap,0,"352,0,2:354,1:355,2:356,3:358,0,2:360,1:361,2:362,3:364,0,2:366,1:367,2:368,3:370,0,2:372,0:373,1:374,2,2:376,1,4:380,3,4:384,1,4:388,2,4:392,3,4:396,1,4:400,0,4:404,1,4:408,3,4:412,3,4")
	
	--boyfriend
	map_add(rightmap,0,"384,0,2:386,1:387,2:388,3:390,0,2:392,1:393,2:394,3:396,0,2:398,1:399,2:400,3:402,0,2:404,0:405,1:406,2,2:408,1,4:412,3,4")
	
	--tankman
	map_add(leftmap,0,"416,3:418,3:420,2,2:422,3:424,1,2:426,3:428,0,4:432,3:433,2:434,3:435,1:436,0:437,1:438,0,2:440,1,4:444,3,4")
	map_add(leftmap,0,"448,3:450,3:452,2,2:454,3:456,1,2:458,3:460,0,4:464,0:466,1:468,2:470,3:472,0,4:476,2,0,true")
	
	--boyfriend
	map_add(rightmap,64,"416,3:418,3:420,2,2:422,3:424,1,2:426,3:428,0,4:432,3:433,2:434,3:435,1:436,0:437,1:438,0,2:440,1,4:444,3,4")
	map_add(rightmap,64,"448,3:450,3:452,2,2:454,3:456,1,2:458,3:460,0,4:464,0:466,1:468,2:470,3:472,0,4:476,2,4")
	
	--tankman 
	map_add(leftmap,0,"544,1:545,0:546,1:547,2:548,3:550,1:551,0:552,1:553,2:554,3:556,2,0,true:560,3,2:562,1:564,3,2:566,0:568,2:570,3:572,0:574,3:576,3:578,3:579,2:580,3:582,2:583,1:584,2:586,1:587,0:588,1:590,0:592,1,2:594,2,2:596,3,2:598,0,2:600,1,2:602,0:603,1:604,3,2:606,0")
	
	--boyfriend
	map_add(rightmap,64,"544,1:545,0:546,1:547,2:548,3:550,1:551,0:552,1:553,2:554,3:556,2:560,3,2:562,1:564,3,2:566,0:568,2:570,3:572,0:574,3:576,3:578,3:579,2:580,3:582,2:583,1:584,2:586,1:587,0:588,1:590,0:592,1,2:594,2,2:596,3,2:598,0,2:600,1,2:602,0:603,1:604,3,2:606,0")
	
	--tankman
	map_add(leftmap,512,"160,3:162,1:164,0:166,1:168,0:169,1:170,3:171,1:172,0,2:174,1:176,3,2:178,1:180,3,2:182,0:184,2:186,3:188,0:190,3") 
	map_add(leftmap,512,"192,3:194,3:195,2:196,3:198,2:199,1:200,2:202,1:203,0:204,1:206,0:208,1,2:210,2,2:212,3,2:214,0,2:216,1,2:218,0:219,1:220,3,2:222,0")
	
	--boyfriend
	map_add(rightmap,512+64,"160,3:162,1:164,0:166,1:168,0:169,1:170,3:171,1:172,0,2:174,1:176,3,2:178,1:180,3,2:182,0:184,2:186,3:188,0:190,3") 
	map_add(rightmap,512+64,"192,3:194,3:195,2:196,3:198,2:199,1:200,2:202,1:203,0:204,1:206,0:208,1,2:210,2,2:212,3,2:214,0,2:216,1,2:218,0:219,1:220,3,2:222,0")
	
	--tankman
	map_add(leftmap,800-32,"32,3:34,3:36,0,2:38,3:40,2,2:42,3:44,0,4")
	map_add(leftmap,800-32,"48,3:49,2:50,3:51,1:52,0:53,1:54,0,2:56,1,4:60,3,4")
	map_add(leftmap,800-32,"64,3:66,3:68,0,2:70,3:72,2,2:74,3:76,1,4:80,3:82,2:84,1:86,0:88,3,4:92,2,0,true")
	
	--boyfriend
	map_add(rightmap,800+32,"32,3:34,3:36,0,2:38,3:40,2,2:42,3:44,0,4")
	map_add(rightmap,800+32,"48,3:49,2:50,3:51,1:52,0:53,1:54,0,2:56,1,4:60,3,4")
	map_add(rightmap,800+32,"64,3:66,3:68,0,2:70,3:72,2,2:74,3:76,1,4:80,3:82,2:84,1:86,0:88,3,4:92,2,4")
	
	music(0)
end

function init_beatmap()
	
	--tankman
	map_add(leftmap,32*1,"0,3:2,3:4,0:6,3:8,2:10,3:12,0,4:16,3:18,3:20,0:21,1:22,0,2:24,1,4:28,3,4")
	map_add(leftmap,32*2,"0,3:2,3:4,0:6,3:8,2:10,3:12,1,4:16,3:18,2:20,1:22,0:24,3,4:28,2,0,true")
	
	--boyfriend
	map_add(rightmap,32*3,"0,3:2,3:4,0:6,3:8,2:10,3:12,0,4:16,3:18,3:20,0:21,1:22,0,2:24,1,4:28,3,4")
	map_add(rightmap,32*4,"0,3:2,3:4,0:6,3:8,2:10,3:12,1,4:16,3:18,2:20,1:22,0:24,3,4:28,2,0")
	
	--tankman
	map_add(leftmap,32*5,"0,3:2,1:4,0:6,1:8,0:9,1:10,3:11,1:12,0:14,1:16,3:18,1:20,3:22,0:24,2:26,3:28,0:30,3")
	map_add(leftmap,32*6,"0,3:2,3:4,2:6,2:8,1:10,1:12,0:14,0:16,1:18,2:20,3:22,0:24,1:26,0:27,1:28,3:30,0")
	
	--boyfriend
	map_add(rightmap,32*7,"0,3:2,1:4,0:6,1:8,0:9,1:10,3:11,1:12,0:14,1:16,3:18,1:20,3:22,0:24,2:26,3:28,0:30,3")
	map_add(rightmap,32*8,"0,3:2,3:4,2:6,2:8,1:10,1:12,0:14,0:16,1:18,2:20,3:22,0:24,1:26,0:27,1:28,3:30,0")
	
	--tankman
	map_add(leftmap,32*9,"0,3:2,1:3,0:4,1:6,3:8,1:9,0:10,1:12,3:14,1:15,0:16,1:18,3:20,1:21,0:22,1:24,0,4:28,1:30,3,2")
	map_add(leftmap,32*10,"0,1,4:4,2,4:8,3,4:12,1,4:16,0,4:20,1,4:24,3,4:28,3,4")
	
	--boyfriend
	map_add(rightmap,32*10,"0,3:2,1:3,0:4,1:6,3:8,1:9,0:10,1:12,3:14,1:15,0:16,1:18,3:20,1:21,0:22,1:24,0,4:28,1:30,3,2")
	
	--tankman
	map_add(leftmap,32*11,"0,0:2,3:3,2:4,3:6,0:8,3:9,2:10,3:12,0:14,3:15,2:16,3:18,0:20,0:21,1:22,0,2:24,1,4:28,3,4")
	map_add(leftmap,32*12,"0,1,4:4,2,4:8,3,4:12,1,4:16,0,4:20,1,4:24,3,4:28,3,4")
	
	--boyfriend
	map_add(rightmap,32*12,"0,0:2,3:3,2:4,3:6,0:8,3:9,2:10,3:12,0:14,3:15,2:16,3:18,0:20,0:21,1:22,0,2:24,1,4:28,3,4")
	
	--tankman
	map_add(leftmap,32*13,"0,3:2,3:4,1:6,3:8,0:10,3:12,0,4:16,3:18,3:20,0:21,1:22,0,2:24,1,4:28,3,4")
	map_add(leftmap,32*14,"0,3:2,3:4,2:6,3:8,0:10,3:12,0,4:16,0:18,1:20,2:22,3:24,0,4:28,2,0,true")
	
	--boyfriend
	map_add(rightmap,32*15,"0,3:2,3:4,1:6,3:8,0:10,3:12,0,4:16,3:18,3:20,0:21,1:22,0,2:24,1,4:28,3,4")
	map_add(rightmap,32*16,"0,3:2,3:4,2:6,3:8,0:10,3:12,0,4:16,0:18,1:20,2:22,3:24,0,4:28,2,0,true")
	
	--tankman
	map_add(leftmap,32*17,"0,3:2,1:3,0:4,1:6,3:8,1:9,0:10,1:12,2,0,true:16,3:18,1:20,3:22,0:24,2:26,3:28,0:30,3")
	map_add(leftmap,32*18,"0,3:2,3:4,2:6,2:8,1:10,1:12,0:14,0:16,1:18,2:20,3:22,0:24,1:26,0:27,1:28,3:30,0")
	
	--boyfriend
	map_add(rightmap,32*19,"0,3:2,1:3,0:4,1:6,3:8,1:9,0:10,1:12,2:16,3:18,1:20,3:22,0:24,2:26,3:28,0:30,3")
	map_add(rightmap,32*20,"0,3:2,3:4,2:6,2:8,1:10,1:12,0:14,0:16,1:18,2:20,3:22,0:24,1:26,0:27,1:28,3:30,0")
	
	--tankman
	map_add(leftmap,32*21,"0,3:2,1:4,0:6,1:8,0:9,1:10,3:11,1:12,0:14,1:16,3:18,1:20,3:22,0:24,2:26,3:28,0:30,3")
	map_add(leftmap,32*22,"0,3:2,3:4,2:6,2:8,1:10,1:12,0:14,0:16,1:18,2:20,3:22,0:24,1:26,0:27,1:28,3:30,0")
	
	--boyfriend
	map_add(rightmap,32*23,"0,3:2,1:4,0:6,1:8,0:9,1:10,3:11,1:12,0:14,1:16,3:18,1:20,3:22,0:24,2:26,3:28,0:30,3")
	map_add(rightmap,32*24,"0,3:2,3:4,2:6,2:8,1:10,1:12,0:14,0:16,1:18,2:20,3:22,0:24,1:26,0:27,1:28,3:30,0")
	
	--tankman
	map_add(leftmap,32*25,"0,3:2,3:4,2:6,3:8,0:10,3:12,0,4:16,3:18,3:20,0:21,1:22,0,2:24,1,4:28,3,4")
	map_add(leftmap,32*26,"0,3:2,3:4,2:6,3:8,0:10,3:12,0,4:16,0:18,1:20,2:22,3:24,0,4:28,2,0,true")
	
	--boyfriend
	map_add(rightmap,32*27,"0,3:2,3:4,2:6,3:8,0:10,3:12,0,4:16,3:18,3:20,0:21,1:22,0,2:24,1,4:28,3,4")
	map_add(rightmap,32*28,"0,3:2,3:4,2:6,3:8,0:10,3:12,0,4:16,0:18,1:20,2:22,3:24,0,4:28,2")
	
	
	music(0)
end

function map_add(_map, _off, _s)
	local _m = lastmap
	if(_map == leftmap) _m = 0
	if(_map == rightmap) _m = 1
	if difficulty == 2 and _m ~= lastmap then
		if _m == 1 then
			srand(seed)
		else
			seed += 1
			srand(seed)
		end
		lastmap = _m
	end
	
	lastrandom = -1
	local _ar = split(_s,":")
	for _a in all(_ar) do
		local _beat = split(_a)
		if difficulty == 2 then
			repeat
				_beat[2] = flr(rnd(4))
			until _beat[2] ~= lastrandom or flr(rnd(8)) == 0
			lastrandom = _beat[2]
		end
		_beat[1] += _off
		add(_map,_beat)
	end
end
-->8
--arrows
function arrows_init()
	leftarrows = {}
	rightarrows = {}
	lefttrails = {}
	righttrails = {}
	combo = 0
	noteheight = 116
	notetime = 1*40
	arrowcols = {2,1,3,4}
end

function arrow_color(_dir)
	if _dir == 0 then
		pal(5,2)
		pal(6,14)
	elseif _dir == 1 then
		pal(5,1)
		pal(6,12)
	elseif _dir == 2 then
		pal(5,3)
		pal(6,11)
	elseif _dir == 3 then
		pal(5,4)
		pal(6,9)
	end
end

function spawn_arrow(_off,_side,_dir,_len,_ugh)
	local _arrow = {x=_dir*14,y=128-(noteheight/notetime),dir=_dir,len=_len,ugh=_ugh}
	
	--local _offset = flr((step - (((_off+1)/32)*(synctime/2))-(notetime)))
	--for i=1,_offset do
	--	_arrow.y -= noteheight/notetime
	--end
	
	if _side == 0 then
		_arrow.x += 4
		add(leftarrows,_arrow)
		if _len > 0 then
			add(lefttrails,{x=_arrow.x,y=128-(noteheight/notetime),dir=_dir,len=_len})
		end
	else
		_arrow.x += 71
		add(rightarrows,_arrow)
		if _len > 0 then
			add(righttrails,{x=_arrow.x,y=128-(noteheight/notetime),dir=_dir,len=_len})
		end
	end
end

function arrows_update()
	
	get_inputs()
	_pressed = {false,false,false,false}
	hashit=false
	
	for _a in all(leftarrows) do
		_a.y -= noteheight/notetime
		if _a.y <= 128-noteheight then
			if _a.ugh then
				char_animate(1,4,true)
			else char_animate(1,_a.dir,true) end
			move_cam(-20,-2)
			poke(0x5f43)
			del(leftarrows,_a)
		end
	end
	
	for _a in all(rightarrows) do
		_a.y -= noteheight/notetime
		--note goes off screen
		if _a.y <= -10 then
			poke(0x5f43,15)
			hp -= 10
			combo = 0
			del(rightarrows,_a)
		end
		--note collision
		if _a.y <= 128-noteheight+15+4 and _a.y >= 128-noteheight-10-8 then
			move_cam(20,0)
			--note hit
			if press[_a.dir+1] and not hashit and not lastpress[_a.dir+1] then
			--if _a.y <= 128-noteheight+2 then
				hashit=true
				poke(0x5f43)
				
				if(difficulty==3) corrupt()
				
				--animate char
				char_animate(2,_a.dir,true)
				
				create_popup(65,42,choose(split"gOOD!,sICK!!"))
				combo += 1
				if(combo >= 10) create_popup(65,50,"combo " .. tostr(combo))
				
				_pressed[_a.dir+1] = true
				--score += ceil(200*(1-abs(_a.y-(128-noteheight))/7))
				score += 20
				hp += 10
				hp = min(maxhp,hp)
				fx_hit(_a.x+3,_a.y+3,arrowcols[_a.dir+1])
				del(rightarrows,_a)
			end
		end
	end
	
	for _t in all(lefttrails) do
		_t.y -= noteheight/notetime
		
		if _t.y <= 128-noteheight and _t.y >= 128-noteheight-(_t.len*12) then
			if(step%6 == 0) char_animate(1,_t.dir,true)
		end
		
		if(_t.y <= 128-noteheight-(_t.len*12)) del(lefttrails,_t)
	end
	
	for _t in all(righttrails) do
		_t.y -= noteheight/notetime
		
		if(_t.y <= 128-noteheight-(_t.len*12)) del(righttrails,_t)
		
		--trail collision
		if _t.y <= 128-noteheight and _t.y >= 128-noteheight-(_t.len*12) then
			--hold button
			if press[_t.dir+1] then
			--if true then
				--score += 2
				if(step%6 == 0) char_animate(2,_t.dir,true)
				hp += 1
				hp = min(maxhp,hp)
				spawn_part(_t.x+3,128-noteheight+7,rnd(),1,0.25,0.25,0.1,0.25,arrowcols[_t.dir+1])
			end
		end
		
	end
	
	--pressing when no note is there
	for i=1,4 do
		if press[i] and not lastpress[i] and not _pressed[i] then
			score -= 1
			--animate char
			char_animate(2,i-1,false)
			
			create_popup(65,42,choose(split"bAD,sHIT"))
			hp -= 10
			combo = 0
			
			sfx(1,3)
			poke(0x5f43)
		end
	end
	
end

function arrows_draw()
	for _t in all(lefttrails) do
		rectfill(camx+_t.x+5,camy+max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+_t.y+(_t.len*12),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+_t.y+(_t.len*12),arrowcols[_t.dir+1])
	end
	for _a in all(leftarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(56,46,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(67,46,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(56,46,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(67,46,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
end

function arrows_draw_downscroll()
	for _t in all(lefttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+6),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+6),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
	end
	for _a in all(leftarrows) do
		if _a.dir < 4 then
			arrow_color(_a.dir)
			if _a.dir == 0 or _a.dir == 3 then
				sspr(56,46,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
			else
				sspr(67,46,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
			end
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(56,46,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
		else
			sspr(67,46,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
end
-->8
--particles
function parts_init()
	parts = {}
end

function fx_hit(_x,_y,_col)
	for i=0,3 do
		spawn_part(_x,_y,(i/4)+0.125,2,0.15,0.125,0.015,0.0675,_col)
	end
end

function spawn_part(_x,_y,_dir,_spd,_fric,_size,_growth,_fade,_col)
	if downscroll > 0 then
		_y = 128 - _y
	end
	add(parts,{
	x=camx+_x,
	y=camy+_y,
	dir=_dir,
	spd=_spd,
	fric=_fric,
	r=_size,
	growth=_growth,
	growthspd=_growth,
	fadeam=_fade,
	fade=0,
	col=_col,
	hs=sin(_dir)*_spd,
	vs=cos(_dir)*_spd,
	lx=_x,
	ly=_y
	})
end

function parts_update()
	for _p in all(parts) do
		if(abs(_p.hs) > 0) _p.hs -= _p.fric*sgn(_p.hs)
		if(abs(_p.vs) > 0) _p.vs -= _p.fric*sgn(_p.vs)
		_p.lx = _p.x
		_p.ly = _p.y
		_p.x += _p.hs
		_p.y += _p.vs
		_p.growthspd += _p.growth
		_p.r += _p.growthspd
		_p.fade += _p.fadeam
		if(_p.fade >= 1 or _p.r <= 0) del(parts,_p)
	end
end

function parts_draw()
	for _p in all(parts) do
		if(_p.fade >= 0.6) fillp(▒)
		if(_p.fade >= 0.85) fillp(░)
		circfill(_p.lx,_p.ly,_p.r,_p.col)
		circfill(_p.x,_p.y,_p.r,_p.col)
		fillp(█)
	end
end
-->8
--characters
function chars_init()
	chars={
		{sp=0,spx=0,spy=0,spw=27,sph=27,x=28,y=102,sx=28,sy=102,hurt=false,rest=0},
		{sp=0,spx=0,spy=0,spw=27,sph=27,x=100,y=102,sx=100,sy=102,hurt=false,rest=0},
		{spx=55,spy=0,spw=29,sph=45,x=64,y=64}
	}
end

function char_animate(_chr,_dir,_good)
	if _chr == 1 then
		if _dir == 0 then
			chars[_chr].spx = 63
			chars[_chr].spy = 92
			chars[_chr].spw = 32
			chars[_chr].sph = 36
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 58
			chars[_chr].spy = 59
			chars[_chr].spw = 38
			chars[_chr].sph = 30
			chars[_chr].y = chars[_chr].sy + 2
		elseif _dir == 2 then
			chars[_chr].spx = 28
			chars[_chr].spy = 86
			chars[_chr].spw = 34
			chars[_chr].sph = 42
			chars[_chr].y = chars[_chr].sy - 2
		elseif _dir == 3 then
			chars[_chr].spx = 97
			chars[_chr].spy = 104
			chars[_chr].spw = 31
			chars[_chr].sph = 24
			chars[_chr].x = chars[_chr].sx + 4
		elseif _dir == 4 then
			chars[_chr].spx = 99
			chars[_chr].spy = 76
			chars[_chr].spw = 26
			chars[_chr].sph = 27
			chars[_chr].y = chars[_chr].sy
			chars[_chr].x = chars[_chr].sx+2
		end
	else
		if _dir == 0 then
			chars[_chr].spx = 0
			chars[_chr].spy = 60
			chars[_chr].spw = 26
			chars[_chr].sph = 28
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 28
			chars[_chr].spy = 30
			chars[_chr].spw = 26
			chars[_chr].sph = 26
			chars[_chr].y = chars[_chr].sy + 4
		elseif _dir == 2 then
			chars[_chr].spx = 0
			chars[_chr].spy = 28
			chars[_chr].spw = 27
			chars[_chr].sph = 31
			chars[_chr].y = chars[_chr].sy - 4
		elseif _dir == 3 then
			chars[_chr].spx = 28
			chars[_chr].spy = 57
			chars[_chr].spw = 27
			chars[_chr].sph = 28
			chars[_chr].x = chars[_chr].sx + 4
		end
	end
	
	chars[_chr].sp = _dir
	chars[_chr].hurt = not _good
	chars[_chr].rest = 30
end

function chars_update()
	for i=1,2 do
		chars[i].x = lerp(chars[i].x,chars[i].sx,0.125)
		chars[i].y = lerp(chars[i].y,chars[i].sy,0.125)
		if chars[i].rest > 0 then
			chars[i].rest -= 1
			if chars[i].rest == 0 then
				chars[i].sp = 0
				chars[i].hurt = false
			end
		end
		if chars[i].rest == 0 then
			if i == 1 then
				if flr(step/(synctime/8)) % 2 == 1 then
					chars[i].sp = -1
					chars[i].spx=0
					chars[i].spy=90
					chars[i].spw=28
					chars[i].sph=27
				else
					chars[i].sp = -2
					chars[i].spx=97
					chars[i].spy=48
					chars[i].spw=32
					chars[i].sph=28
				end
			else
				if flr(step/(synctime/8)) % 2 == 1 then
					chars[i].spx=0
					chars[i].spy=0
					chars[i].spw=27
					chars[i].sph=27
				else
					chars[i].spx=28
					chars[i].spy=0
					chars[i].spw=26
					chars[i].sph=29
				end
			end
		end
	end
	
	--girlfriend
	if flr(step/(synctime/8)) % 2 == 1 then
		chars[3].spx=85
		chars[3].spy=0
		chars[3].spw=29
		chars[3].sph=47
	else
		chars[3].spx=55
		chars[3].spy=0
		chars[3].spw=29
		chars[3].sph=46
	end
	
end

function chars_draw()
	--girlfriend
	palt(0,false)
	palt(10,true)
	local lx = camx/4
	local ly = 0
	if flr(step/(synctime/16)) % 2 == 0 then
		sspr(85,36,30,11,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13)
		sspr(115,18,13,15,lx+2+chars[3].x-16-12-1,ly+chars[3].y+12, 13, 15, true)
		sspr(115,18,13,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		--sspr(104,57,24,23,lx+chars[3].x-flr(29/2)+4,ly+chars[3].y+4-flr(47/2)-1)
	else
		sspr(55,35,30,11,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13)
		sspr(115,33,12,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		sspr(115,33,12,15,lx+2+chars[3].x-16-12,ly+chars[3].y+12, 12, 15, true)
		--sspr(98,80,30,22,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(46/2))
	end
	if flr(step/(synctime/16)) % 4 == 0 then
		sspr(55,22,30,13,lx+chars[3].x-flr(29/2)-1,ly+chars[3].y+4-flr(47/2)+22,32,14)
		sspr(90,0,24,23,lx+chars[3].x-flr(29/2)+4,ly+chars[3].y+4-flr(47/2),26,22)
	elseif flr(step/(synctime/16)) % 4 == 1 then
		sspr(55,22,30,13,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22)
		sspr(90,0,24,23,lx+chars[3].x-flr(29/2)+4,ly+chars[3].y+4-flr(47/2)-1)
	elseif flr(step/(synctime/16)) % 4 == 2 then
		sspr(55,22,30,13,lx+chars[3].x-flr(29/2)-1,ly+chars[3].y+4-flr(47/2)+22,32,14)
		sspr(55,0,30,22,lx+chars[3].x-flr(29/2)-2,ly+chars[3].y+4-flr(46/2)+1,32,21)
	elseif flr(step/(synctime/16)) % 4 == 3 then
		sspr(55,22,30,13,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22,30,13)
		sspr(55,0,30,22,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(46/2))
	end
	pal()
	
	for i=1,2 do
		palt(0,false)
		palt(3,true)
		local _c = chars[i]
		if(_c.hurt) fade(7)
		--if i == 1 then sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph,true)
		if i == 1 then
			palt(3,false)
			palt(8,true)
			if _c.sp == -1 or _c.sp == -2 or _c.sp == 3 or _c.sp == 4 then
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-10-_c.sph,_c.spw,_c.sph)
				if _c.sp == -2 then sspr(0,118,24,10,_c.x+2-flr(_c.spw/2),_c.y-10)
				else sspr(0,118,24,10,_c.x-flr(_c.spw/2),_c.y-10) end
			else
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
			end
		else
			sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
		end
		pal()
	end

end
-->8
--popups system
function popups_init()
	popups={}
end

function create_popup(_x,_y,_txt)
	add(popups,{
	x=_x,y=_y,sy=_y,txt=_txt,fade=0
	})
end

function popups_update()
	for _p in all(popups) do
		if _p.fade < 1 then
			_p.y = lerp(_p.y,_p.sy-8,0.125)
			_p.fade += 1/15
			if _p.fade >= 1 then
				del(popups,_p)
			end
		end
	end
end

function popups_draw()
	local lx = camx/2
	local ly = camy/2
	for _p in all(popups) do
		if(_p.fade >= 0.5) fillp(▒)
		if(_p.fade >= 0.75) fillp(░)
		for i=-1,1 do
			for j=-1,1 do
				print(_p.txt,lx+_p.x+i-#(_p.txt)*2,ly+_p.y+j,0)
			end
		end
		print(_p.txt,lx+_p.x-#(_p.txt)*2,ly+_p.y,7)
		fillp(█)
	end
end
-->8
function corrupt()
	--sprite corruption
	for i=1,10 do
		poke(rnd(0x1fff),rnd(255))
	end
	
	--music/sound corruption
	if(flr(rnd(25))==1) poke(0x5f40+rnd(3),rnd(255))
	for i=1,5 do
		poke(rnd(0x42ff-0x3200)+0x3200,rnd(255))
	end
	
	--chance to flip/turn screen
	if(flr(rnd(1000))==0) poke(0x5f2c,rnd({0,129,130,131,133,134,135}))
	
end
__gfx__
3333333333333322222223333333333333333332222222223333333aaaaaaaaaaaa2222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa22aaaaaaaaaaabbb1111bbbbbb
33333333332222eeeee28033333333333333322eeeeeee280333333aaaaaaaaaaaaa242222aaaaaaaaaaaaaaaaaaaaaaaaaaaaa222aaaaaaaaabb11ccc111bbb
3333333332eeeeeeee28880333333333333332eeeeeee2888033333aaaaaaaaa222222444442aaaaaaaaaaaaaaaaaaaaaa222222442aaaaaaaab1c1cccc1c1bb
333333332eeeee1eee2888033333333333332eeee6eee2888033333aaaaaaa24444444444f442aaaaaaaaaaaaaaaaaaa244444222222aaaaaaa1ccc1ccc1c1bb
333333330000e16ee28888803333333333330cee16ee28888803333aaaaaa244444444f44f444aaaaaaaaaaaaaaaa2aa44444444444442aaaaa11cc11111c1bb
33333331066606cee288888033333333333066606cee28888803333aaaaaa4ff44ff44fff44442aaaaaaaaaaaaaa2aa24f444444444f442aaaab1c11c1c11111
3333333166c666cce20888803333333333166c666c0e20888803333aaa2aa4444f4f4f44444442aaaaaaaaaaaaaa2a22fffffff4f4fff44aaaab11c1c11cc1c1
33333316ccccc6cc1088880720003333316cc0cc6cce08888822000aaa2a224444444444444442aaaaaaaaaaaaa24244444f4f4ff4444442aaab1b1cccc1c11b
33333316cc0cccc61000007721cc3333316cc0ccccc6000080771ccaaa44244444444444444422aaaaaaaaaaaaa244424444444444444444aaabbbb1111111bb
333333111cc0ff6f0f6cc12f2310330003116c01fff0f6cc1f2f010aaa24242224442ee244ee42aaaaaaaaaaaaaa22244444244444444444aaabb00000000bbb
333333336c1f0ff20ff1f14423333016d036c1f0ff20ff11cf22333aaaa22222e24e220e22fe2422aaaaaaaaaaaaa2422e2224e244444424aaab0000000000bb
33000331c12ff02f47fff00333330dd16d0c12ff02f47fff2223333aaaaa2222e00ee402e2f2222aaaaaaaaaaaaaa2222002ee20224ee442aaab00000000000b
306dd03112f774777f772723333300dd00012f774777f7722333333aaaaa2242ee0eff4f422224aaaaaaaaaaaaaa22242e00eee02e22e222aaa000000000000b
01d16d2332777f77f772772333330d0d16022777f77f77276233333aaaaa2442ef4fffff4424442a2aaaaaaaaaaa2242ff44eff4f4422222aaa000777777700b
01d0dd7232f777ff722267623333301610722f777ff722677233333aaaaaa42efff2082f224444442aaaaaaaaaaa2442fffffffff222242aaaa000777777700b
010d602722222228866627723333330007273222228866667723333aaaaaa40effff88ff42444442aaaaaaaaaa2aa240fff2082ff24244aa22a000777077700b
30160072222266e77e670ff23333332f772f26666e66e7202223333aaa2a444002222222ef244442aaaaaaaaaa22244400ff88ff2242442242ab0000070000bb
330007771cc777e7ee70f7f233333327777726077e7ee72ff433333aaa22444442888884ffe444442aaaaaaaaaa24444e2880042e42444442aabb007007700bb
333277f71ccc10000011777f1333332ff7740cc077ee702fff33333aaa244444e02222224ff444442aaaaaaaaaa224444288224ef2444442aaa0001111aaaaaa
3332f7ff2fff21001ccc1f7f12333332fff771110111cc177fc3333aaaa24444e00000222ff444422aaaaaaaaaa224440222224ff24444442aa00655551111aa
333322228eeee0f8112fcccc8233333224fffff2111cccc11113333aaaaa444e2efff4400ef2442aaaaaaaaaaaaa244200000244f24444442aa116550000551a
33333326767e2e88128ee112823333333222eeef00102f1cc123333aaaaa24ff2fffffffe0ffe22aaaaaaaaaaaaaa422effff000fe244442aaa1165051110651
333332ed7d8288828286666d23333333333267ee2f212feeee23333aaa111ef42ef222eff0ef22f211aaaaaaaaaa2ef2fffffffe2fffe22aaaa1165055111051
33332eee2228222228877d2d7e2333333277767288ee8e777233333a11555552ef2fff2ee46666555511aaaa1112ff2eff22efff2f22fe11aaa1165016611051
3333288e8882d6d62287e888e87233332ee27728882ee7777722333a1055622fff2fee22111110665051aa11555555eff2ff4ef46666655511a1165500111651
33333277676dd00222ee8888276233332ee82882e62287eeeee8233150122ffff22ffe211111666060151a10555624ff2feef2411110066051a1165550006551
333333222220033330677777662333327882222e0008ee888882233156288822222eff0001666111065511501522eff41ffef111116661061511165000055551
33333333333333333302222222333332776776233302ee8888262330560228820202ef255611111106550155628822221eff2111166111106511150111106551
333333333333322223333333333333332222223333066777776233305611122111022fe220111111161500556022220210ef4201611111106501150511110551
3333333333332eeee2233333333333333333333333302222222333355611111111022ff8201111111615505161111111052ff22611111110650005056611051a
3333333333000eeeeee223333333333333333333222222233333333556011111111028f8211111110615555161111111052ff82211111110655005000111051a
33333333316660eee1eee2233333333333333222eeeee2803333333556011111100002882001111106155551611111111028f88211111110655001101111651a
333333331660c60061eeeee23333333333332eeeeeee2888033333355560111000000022200001106155555516111000000288820001110615500011000011aa
333333316cc0cc60c0eee228033333333332eeee1eee28880333333555566600000000000000006615555555516000000000222000000061555000111aaaaaaa
333333311c6c0cc6c0e2288803333333333100e16ee288888033333555551166666666666666661555555555551660000000000000066615555006555111aaaa
3333333316cc0cc6cc28888880333333330c6606cee28800803333355555566000000011000006655555555555555111111111111111555555511655000511aa
33333331111101cccc88008880333333331c6666cce280088022333555566011111111111111660665555555555666666666666666666555555116505110651a
33333331322ff0161600088880333333316c06c6cce2808802f20c0555600111111111111116611006555555566000000000000000000665555116505511051a
333333332ffff06f0008888880333333316cc0cccc66000007721c1555601111111000000161111106555555601111111111111116661106555116501611051a
333333332777f4200f161180023333331611cc00c6601f6c61f2033055611111110555555011111116550556011111111111111166111110655115500011651a
33333330007777f4f416cc17f23333331131cc100112f4f61c13333011611111110555555011111116110050111111111100006611111111050115555006551a
3333330d0d07f777227f1c77711333333316c0fff2f0727ff233333011601111110555555011111106110010111111111055550111111111010115500055551a
33333010dd107ff22874242f21cc3333331612727070277f2233333011601111111000000111111106110010111111111055550111111111010115011106551a
3333306d0160227728f23222301c333332212f77007777726623333011560110000000000000011065110016011111100000000001111110610115051110551a
32220011d6d0662222233333330033224ff22000772277266623333a0115660000000000000000665110a01560110000000000000000110651011505611051aa
32ff7006dd06886666623333333332f777710d6107f882622233333a0111556660000000000666551110aa0155660000000000000000066510a11500011051aa
32f77f00002e76862666233333332777f770661d60222684ff43333000005500000000055550000888888a0111556666000000006666655110a00100110651aa
2f77472f266eee7622262333333327474720dd06007e77e077733330000566550000005666650008888888888888888888888888888888888880001000111aaa
2ff772ff276777772ff2233333332f4f222011d0d0000011c7113330000566665000056666665008888888888888888888888888888000000000008888888888
2f747f22e20007772ff2333333333222ff21011110111c2cccc13330555556666500566666666508888888888888888888888888800000000000000888888888
2f7722eeee2000cc177f133333333333226770000e8222eeccce2330566666666650566666666508888888888888888888888888000000000000000888888888
3222328eeee0e111cf777133333333332e77e7828882ee8676e22230566666666655666666666658888888888888888888888888000000677777760088888888
333326767e2e80811177f11333333332eee22228222e28767227ee20566666666655665666656658888888888888888888888888000677777777777608888888
3332ed7d82888de861111113333333328ee88882e000087e8888e820566666666650555666655508888888888888888888888880006777777777777708888888
332eee22282222e877227e823333333327767720333302ee88882720555556666500005666650008888888888888888888888880007777777777777708888888
3278ee8882d6d228e888827233333333322222333333306676776230000566665000005666650008888888888888888888888880007777777777777708888888
327782222d00308ee888826233333333333333333333332222222330000566550000005555550008888888888888888888888880007777777777777708888888
33277777220330622888766233333333333333333332222233333330000055000008888888888888888888888888888888888880006777777777777608888888
3332222222333306667762223333333333333333222eeee203333333888888888888888888888888888888888888888888888880000677760006776008888888
3333333333333332222223333333333333333222eeeee82880333333888888888888888880000008888888888888888888888880000000000600000088888888
3333333333322222333333333333333333332eeeeeeee28888033333888888888888888000000000008888888888888888888888000006600006600880707888
33333333322eeeee222233333333333333332eeee6ee828088033333888888888888880000000000000088888888888888888888000007077707000800060788
3333333322eeeeeeee282333333333333333000e16ee280888803333888888000088800000000000000008888888888888888888800000000000000806066088
33333333000ee1eee288803333333333333066600c1e2008888233338888800000088000000000000000088888888888888888887700060000060000d0606088
333333316660066e2888803333333333333160c60cc18088882f00118888000000088000000000000000008888888888888888800600077666770000d0d00008
3333331066660c1e28888803333333333316c0ccc6c10200007721c18880000000000000000000000000008888888888888008760000077777776010d0010508
33333160cccc6c0288808803333333333316cc0c11c6006c110f2333880010001000000000000000000000888888888888000006008807777777701000566008
3333311c0ccccc02800888033333333333111c100f6200f6f1142333880010000170000000000000000000088888888888000000001167777777601101000010
333333160011c668088888223333333333336c1200ff0f4ff2223333880001000016000000000000000066088888001888000000001016777776080101100101
3333316c100f61f0000882f23333333333316132f0274727f2333333881100000080000000000000000677080001100188000000000001000000080111110001
333331112f0f1f0016c00771c13333333331132f7477f88723333333881000000010000067600000067776000500100188800000000001000000010001000001
333331332747f20ff11cf2f01c0333333223330007f2887262333333888000000110000077777777777760060060000188800000000111000000000000111018
33333332f777774777f04223300333322ff210d11022222672333333888100100188000077777777777706006505000188880000000101000000000100811188
3333333277f7777277f2223333333327777d0d61600e762222333333888811101888800077777777777600060500010188888000000001088880001018888888
33333333277fff882f27233333333277f47100060d0770ff03333333888888118888880067777600660006006050001188888800000110008800000008888888
3333223302000228226672333333324ff4f601ddd10cc17721333333888888888888880600000066000000000500011888888880011100008800000001888888
3222ff210016086226222233333332f4f2ff201110cc1c1772133333888888888888888060000600000088000081118888888888888800000088888888888888
32f777100d60d0ee7727703333333322222f2800002f1cc111133333888888888888880000ee0700000008888888888888888888800000000000088888888888
3277471010dd1000001c7113333333326f22e2e8222ee1cc11333333888888888880000000000000000000800008888888888888000000000000008888888888
2f4f4f000111d011ccc11c113333332ed7d828882ee8766d82333333888888888000100000008888000000000008888888888880000000000000000888888888
2ff42ff00101000112f1cc12333332eee7222222d2877227e2333333888888888000011000088880001000000088888888888880000000000000000888888888
22222f0080000f8112feeee23333268e888820062287e888e2233333888888888000000000008800000110011888888888888880000000000000006088888888
3333327767d62e82e8e7776223332767662033302ee8888826233333888888888000000000000800000000000888888888888800067600000006777088888888
333332ee277288822ee77777e2232222222333306228888762333333888888880000000000000800000000018888888888888800077777777777777088888888
333332ee82882d6622877eeeee623333333333330667676623333333888888880000000011118800000000100188888888888800067777777777777088888888
333332782222d200308ee88882723333333333333222222233333333888888800000000000088800000000000018888888888800006777777777777088888888
3333332776720033302ee88827628888888888888800008888888888888888800000011111888880000000000018888888888800000006000067776088888888
33333332222233333066777766238888888888880000000088888888888888800000000000188888880000000018888888888880000000666000000088888888
33333333333333333300222222338888888888000000000000888888888888880000000000188888888000000188888888888880006600077776000800088888
88888888888888888888888888888888888888000067777760088888888888888888888888888888888888888888888888888880006077707777000060078888
888888800000000000888888888888888888800067777777776088888888888888888888888888888888888888888888888888880000e0067776000506607888
88888800000000000000888888888888888800067777777777708888888888888888888888888888888888888888888888888888701170000000000050606888
88888800000000000000888888888888888800677777777777760888888888888888888888000000088888888888888888888888010011100670080000060888
888880000000000000000888888888888888007777777600677708888888888888888888000000000000088888888888888888867100000167700100d0d08888
88880000067777777760088888888888888000677777606006760088888888888888888000000000000000888888888888888000011010017770100000000888
88880006777777777776008888888888888000077600000600000088888888888888888000000000000000888888888888880001100110077776100056600888
88880007777777777777608888888888888000060007777066000880008888888888880006777777600000888888888888880000100001677776110000000888
88880007777777777777708888888888888000006607000077600800070888888888880007777777777776088888888888800011110000067600100000011888
88880007777777777777708888888888888000000670ee0000000060607088888888800007777777777777608888888888800010001100100000111100008888
88880007777777777777608888888888888800000000000000000d06060088888000800007777777777777708888888888810010001011000000011000008888
8888000677776000677608888888888888888000000000000000800060d008880000110067777777777777708888888888810000110000010000001100018888
8888000000000770000008888888888888888800000000000008800dd00608880011101067777777777777708888888888881100001010018800001811188888
8888800066600006600088800088888888888880000000000008000d006001800000001006777600067000000888888888888811111101188800110188888888
88888800060777077000880607088888888888870006000060000100550011800010111000000006000707000110018888888888100000000000000018888888
88888770000000000008800660708888888888800007000076000100010000800110810106067770600605050010001888888888888000000000008888888888
8888006000000000600880d000008888888888600007600670800101100000800010100100070000607656005010001888888888800000000000000888888888
8886700006000067700080d0d0d08008888800000807777770888010100100800010000170607707706065dd0000001888888888000000000000000888888888
00006008077777777000100000500000880000008807777770888801111000800001001600000000001050d00000001888888888000000000000000008888888
0000000811777777780100056600100008000000886777777088888000000880000000100000660006005dd00100101888888888000006777777777600888888
00000000016777776801000000008110000000001807777770888888888888880000001088807777776000001110108888888880000007777777777760888888
00000000001677600181100000008811000100001806777760888888888888888000018888807777777088110001188888888880000007777777777770888888
00000001101000000181010001188881000100001800067600888888888888888801188888806777776088881111888888888801000007777777777770888888
00000000110000000011110100088888000010018000000000088888888888888888888888800067760088888888888888801800100006777777777770888888
80000000010000000001011000088880001001180000000000008888888888888888888888810000000018888888888888000100100000777777777770888888
80000000001008000001101100188880001001180000008000008888888888888888888888810000000001188888888888000100100000677776000760888888
88000000011088800111010111888800000001800000088000018888888888888888888888100000000000188888888888800101000000000000660000067088
88800001100088800010018888888800100018810000088000111888888888888888888881000000880000018888888888800101000000007770706006600788
8888888888888888888888888888880010101801100001800000188888888888888888888101100888800110188888888800100180000000e007770050060008
88880000000018800000001888888888111188000000018000001888888888888888888881000008888000101888888880001100011000007700008006606108
88880000000018000000001888888888888888000000018000000188888888888888888810000001880000000188888880000100001000600060000000060500
88810000000018000000001888888888888888000000188000000188888888888888888810000000180000000188888880001000111006777770000005050000
88810000000018000000001888888888888880000000188000011188888888888888888810000000180000000018888880000100100677777760110000000600
88811100000118000000110118888888888881000000188000001011888888888888888810000000188000000018888880001101186777777708881001000000
88000010000018000000000018888888888801100000188800000000188888888888888810000000188000000011888880000000100677777608888101000010
80000000000018800000000018888888888000000000188800000000188888888888888011100000188000001100118888000001800006776018008811111100
80000000001188880000000118888888888000000001188880000000188888888888880000010000188000000000018888888888000000000001008810100000
80000000118888888880011188888888888000000011888888000001188888888888880000000000188800000000018888888880000000000000008881111000
88111111888888888888888888888888888800111188888888880011888888888888880000000011888888000111118888888810000008880000108888881118
__label__
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0f0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0f0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0f0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffff55ffffffffff555555fffffffff5555ffffffffff55ffffffffffffffffffffffff55ffffffffff555555fffffffff5555ffffffffff55fffffffff
fffffff55665fffffffff566665ffffffff566665ffffffff56655ffffffffffffffffffff55665fffffffff566665ffffffff566665ffffffff56655fffffff
ffffff566665fffffffff566665fffffff56666665fffffff566665ffffffffffffffffff566665fffffffff566665fffffff56666665fffffff566665ffffff
fffff5666655555ffff5556666555ffff5666666665fff5555566665ffffffffffffffff5666655555ffff5556666555ffff5666666665fff5555566665fffff
ffff56666666665fff566566665665fff5666666665fff56666666665ffffffffffffff56666666665fff566566665665fff5666666665fff56666666665ffff
ffff56666666665fff566666666665ff566666666665ff56666666665ffffffffffffff56666666665fff566666666665ff566666666665ff56666666665ffff
ffff56666666665ffff5666666665fff566566665665ff56666666665ffffffffffffff56666666665ffff5666666665fff566566665665ff56666666665ffff
ffff56666666665ffff5666666665ffff5556666555fff56666666665ffffffffffffff56666666665ffff5666666665ffff5556666555fff56666666665ffff
fffff5666655555fffff56666665fffffff566665fffff5555566665ffffffffffffffff5666655555fffff56666665fffffff566665fffff5555566665fffff
ffffff566665fffffffff566665ffffffff566665ffffffff566665ffffffffffffffffff566665fffffffff566665ffffffff566665ffffffff566665ffffff
fffffff55665ffffffffff5555fffffffff555555ffffffff56655ffffffffffffffffffff55665ffffffffff5555fffffffff555555ffffffff56655fffffff
fffffffff55fffffffffffffffffffffffffffffffffffffff55ffffffffffffffffffffffff55fffff9fffffffffffffffffffffffffffffffff55fffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9999ffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9999999ffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff999999999fffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9999999999999fffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff999999999999999ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff999999999999999999ffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff9fffffffffffffffffffffffffffffffffffffffff9999999999999999999999ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffff9999fffffffffffffffffffffffffffffffffffff99999999999999999999999999fffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffff9999999fffffffffffffffffffffffffffffffff9999999999999999999999999999999fffffffffffffffffffffffffffff
ffffffffffffffffffffffffff9999999999ffffffffffffffffffffffffffffff99999999999999999999999999999999999fffffffffffffffffffffffffff
fffffffffffffffffffffffff999999999999ffffffffffffffffffffffffff9999999999999999999999999999999999999999fffffffffffffffffffffffff
fffffffffffffffffffffff9999999999999999fffffffffffffffffffff999999999999999999999999999999999999999999999fffffffffffffffffffffff
fffffffffffffffffffff9999999999999999999fffffffffffffffff99999999999999999999999999999999999999999999999999fffffffffffffffffffff
fffffffffffffffffff9999999999999999999999fffffffffffff9999999999999999999999999999999999999999999999999999999fffffffffffffffffff
fffffffffffffffff9999999999999999999999999ffffffffff99999999999999999999999999999999999999999999999999999999999fffffffffffffffff
fffffffffffffff9999999999999999999999999999ffffff99999999999999999999999999999999999999999999999999999999999999999ff999fffffffff
ffffffffffff99999999999999999999999999999999fff999999999999999999999999999999999999999999999999999999999999999999999ff9999999999
ffffffff999999999999999999999999999999999999999fffff999999999999999999999999999999999999999999999999999999999999999999ff99999999
fffff99999999999999999999999999999999999999999999999ffff9999999999999999999999999999999999999999999999999999999999999999ff999999
ff999999999999999999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999999ff9999
9999999999999999999999999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999fff9
999999999999999999999999999999999999999999999999999999999999999999ffff999999999999999999999999999999999999999999999999999999999f
9999999999999999999999999999999999999999999999999999999999999999999999fff9999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999992299999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999222999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999922222244299999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999992444442222229999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999992994444444444444299999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999929924f444444444f4429999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999992922fffffff4f4fff449999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999924244444f4f4ff4444442999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999244424444444444444444999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999922244444244444444444999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999992422e2224e244444424999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999992222002ee20224ee442999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999922242e00eee02e22e222999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999992242ff44eff4f4422222999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999992442fffffffff2222429999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999299240fff2082ff2424499229999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999999922244400ff88ff22424422429999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999924444e2880042e4244444299999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999224444288224ef2444442999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999224440222224ff2444444299999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999999999244200000244f2444444299999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999999422effff000fe244442999999999999999999999999999999999999999999999999999
9999999999999999999990000000000099999999999999999999999992ef2fffffffe2fffe229999999999999999999999999999999999999999999999999999
999999999999999999990000000000000099999999999999999991112ff2eff22efff2f22fe11999999999999999999999999999999999999999999999999999
99999999999999999999000000000000009999999999999999911555555eff2ff4ef466666555119999999999999999999999999999999999999999999999999
99999999999999999990000000000000000999999999999999910555624ff2feef24111100660519999999999999999999999999999999999999999999999999
999999999999999999000006777777776009999999999999991501522eff41ffef11111666106159999999999999999999999999999999999999999999999999
99999999999999999900067777777777760099999999999999155628822221eff211116611110659999999999999999999999999999999999999999999999999
999999999999999999000777777777777760999999999999990556022220210ef420161111110659999999999999999999999999999999999999999999999999
9999999999999999990007777777777777709999999999999905161111111052ff22611111110659999999999999999999999999999999999999999999999999
9999999999999999990007777777777777709999999999999955161111111052ff82211111110659999999999999999999999999999999999999999999999999
99999999999999999900077777777777776099999999111000551611111111028f88211111110650001111999999999999999999999999999999999999999999
99999999999999999900067777600067760999991111555600555161110000002888200011106150065555111199999999999222222299999999999999999999
99999999999999999900000000077000000999915500055611555516000000000222000000061551165500005519999992222eeeee2809999999999999999999
9999999999999999999000666000066000999000601150561155555166000000000000006661555116505111065199992eeeeeeee28880999999999999999999
999999999999999999990006077707700099060701115056115555555511111111111111155555511650551110519992eeeee1eee28880999999999999999999
999999999999999999977000000000000990066070161056115555556666666666666666665555511650166110519990000e16ee288888099999999999999999
999999999999999999006000000000600220d0000011055611555566000000000000000000665551165500111651221066606cee288888099999999999999999
999999999999999996700006000067700020d0d0d00055561155560111111111111111666110655116555000655122166c666cce208888099999999999999999
99999999999222000060020777777770001000005050005611556011111111111111166111110651165000055551216ccccc6cc1088880720022999999999999
99992222222222000000021177777772010005660001110511050111111111100006611111111051150111106551216cc0cccc61000007721c22222222299999
222222222222220000000001677777620100000000111505110101111111110555501111111110111505111105514111cc0ff6f0f6cc12f22122222222222222
222222222222220000000000167760012110000000116505000101111111110555501111111110100505661105142426c1f0ff20ff1f14422222222222222222
22222222222242000000011010000001410100011011000500016011111100000000001111110610050001110000421c12ff02f47fff00424242222222222222
222224242424240000000011000000001111010006111011000156011000000000000000011065100110111106dd04112f774777f77272242424242424222222
42424242424242400000000100000000010110000444444444401556600000000000000000665104444444401d16d2442777f77f772772424242424242424242
24242424242424200000000010040000011011001444444444401115566660000000066666551104444444401d0dd7242f777ff7222676242424242424242424
424242424244444400000001104440011101011144444444444444444444444444444444444444444444444010d6027222222288666277244444424242424242
24244444444444444000011000444000100144444444444444444444444444444444444444444444444444440160072222266e77e670ff244444444444442424
444444444444444444000000001440000000144444444444444444444444444444444444444444444444444440007771cc777e7ee70f7f244444444444444444
444444444444444444000000001400000000144444444444444444444444444444444444444444444444444444277f71ccc10000011777f14444444444444444
4444444444444444410000000014000000001444444444444444444444444444444444444444444444444444442f7ff2fff21001ccc1f7f12444444444444444
444444444444444441000000001400000000144444444444444444444444444444444444444444444444444444422228eeee0f8112fcccc82444444444444444
44444444444444444111000001140000001101444444444444444444444444444444444444444444444444444444426767e2e88128ee11282444444444444444
444444444444444400001000001400000000004444444444444444444444444444444444444444444444444444442ed7d8288828286666d24444444444444444
44444444444444400000000000144000000000444444444444444444444444444444444444444444444444444442eee2228222228877d2d7e244444444444444
4444444444444440000000001144440000000144444444444444444444444444444444444444444444444444444288e8882d6d62287e888e8744444444444444
44444444444444400000001144444444400111444444444444444444444444444444444444444444444444444444277676dd00222ee888827644444444444444
44444444444444441111114444444444444444444444444444444444444444444444444444444444444444444444422222004444067777766244444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444400000000444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444000000000044444444411114444444444444444444444444444444444444444444444444444444
4444444444444444444442222222222222222222222222222200000000000222333311ccc1113333333333333333333333333333334444444444444444444444
4444444444444444444442888888888888888888888888888000000000000888bbb1c1cccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
4444444444444444444442888888888888888888888888888000777777700888bb1ccc1ccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
4444444444444444444442888888888888888888888888888000777777700888bb11cc11111c1bbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
4444444444444444444442888888888888888888888888888000777077700888bbb1c11c1c11111bbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
4444444444444444444442888888888888888888888888888800000700008888bbb11c1c11cc1c1bbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
4444444444444444444442222222222222222222222222222220070077002222333131cccc1c1133333333333333333333333333334444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444441111111444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

__sfx__
1d0200200b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b0700b070
000200000f860200201b0101b0301b020150100b01006010030200002022000260002100019000110000e0000a000080000800006000040000400004000030000100000000010000000000000000000000000000
010200200407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073
000100001c3501e3502035022350233502635027350293502b3502c3502a35026350203501c350143500e350083500635004350033500435006350073500a3500e35011350103500c35004350023500135002350
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb0b00000b355003000b3550030012355003000b355003000e355003000b355003000a3400a3400a3400a355123551335512355103550e3550d3550b3400b3450a3400a3400a3400a3550b3400b3400b3400b355
bb0b00000b355000000b3550000012355000000b355000000e355000000b355000000a3400a3400a3400a3550b3400b3550e3400e355133401335512340123550a3400a3400a3400a34500b5000b5511b000b300
2b0b0000175550c500175550c5001e5550c500175550c5001a5550c500175550c500165401654016540165551e5551f5551e5551c5551a5551955517540175451654016540165401655517540175401754017555
2b0b0000175550c500175550c5001e5550c500175550c5001a5550c500175550c5001654016540165401655517540175551a5401a5551f5401f5551e5401e5551654016540165401654517540175401754017555
010b00000b073000030c000000030b0730000300003000030b0730000300003000030b0730000300003000030b0730000300003000030b0730000300003000030b0730000300003000030b073000030000300003
010b00000b0730b0000b0000b0000b0730b0000b000000000b0730000000000000000b0730000300003000000b073000030b073000030b073000030b073000000b073000000b073000000b0730b0730b0730b073
310b00000b0730c8500c8500c8500c8500c8500c8500c8500b67318800188001880018800188001880018800188001880018800188000b0730c8530c8530c8530b67318800188001880018800188001880018800
bb0b00001e3401e3451a3401a34517340173451a3401a3451e3451c3451a345193451734017345163401634517340173451234012345173401734510340103450e3400e3450d3400d3450b3400b3451634016345
bb0b000017340173451a3451934517340173451c3451a34519340193451f3451e3451c3401c3451a3401a3451c3401c3451f3401f3451e3401e3451c3401c3451a3401a3451c3401c3451a345123451634016345
2b0b00002a5402a5452654026545235402354526540265452a5452854526545255452354023545225402254523540235451e5401e54523540235451c5401c5451a5401a545195401954517540175452254022545
2b0b0000235402354526545255452354023545285452654525540255452b5452a5452854028545265402654528540285452b5402b5452a5402a545285402854526540265452854028545265451e5452254022545
bb0b00001e3301c3451a3451934517330173451e3301c3451a3451934517330173451e3301c3451a3451934517330173451e3301c3451a3451934517330173451c3301c3301c3301c3351a3301a3351933019335
2b0b00002a53028545265452554523530235452a53028545265452554523530235452a53028545265452554523530235452a53028545265452554523530235452853028530285302853526530265352553025535
ba0b00001c3401c3451a3451934517340173451c3401c3451a3451934517340173451c3401c3451a3451934517340173451e3401e3451c3451a34519340193451a3401a3401a3401a34519340193401934019345
bb0b00001a3301a3301a3301a33519330193301933019335163301633016330163351333013330133301333512330123301233012335133301333013330133351633016330163301633517330173301733017335
2b0b00002854028545265452554523540235452854028545265452554523540235452854028545265452554523540235452a5402a545285452654525540255452654026540265402654525540255402554025545
bb0b00001e34523345263452a34523340233451e34523345263452a34523340233450cb500cb551e3001e30023340233451e3401e34523340233451c3401c3451a3401a34519340193451a3451a3351634016345
bb0b000017340173451a3451934517340173451c3451a34519340193451f3451e3451c3401c3451a3401a3451c3401c3451f3401f3451e3401e3451c3401c3451a3401a3451c3451a34519340193451634016345
2b0b00001e54523545265452a54523540235451e54523545265452a54523540235451e5401e5401e5401e54523540235451e5401e54523540235451c5401c5451a5401a54519540195451a5401a5451654016545
2b0b000017540175451a5451954517540175451c5451a54519540195451f5451e5451c5401c5451a5401a5451c5401c5451f5401f5451e5401e5451c5401c5451a5401a5451c5451a54519540195451654016545
310b00000b0730c8530c8530c8530c8530c8530c8530c8530b673188001880018800188001880017673188000b600188000b000188000b0730c8530c8530c8530b67318800188001880018800188001880018800
310b00000b0730c8530c8530c8530c8530c8530c8530c8530b673188001880018800188001880017600188000b600188000b0730c8330b0730c8530c8530c8530b67318800188001880018800188000b0730c833
310b00000b0730c8530c8530c8530c8530c8530b0730c8530c8530c8530c8530c8530b0730c8530c8530c8530c8530c8530b0730c8330b0730c8530c8530c8530b60018800188001880018800188000b0730c833
310b00000b00018800188001880018800188000b000188000b6731880018800188000b00018800176731880018800188000b000188000b0001880018800188000b67318800188001880018800188000b00018800
010b00000c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c823
310b00000b00018800188000b6000b643188000b000188000b60018800188000b6000b64318800176001880018800188000b0000b6000b6431880018800188000b60018800188000b6000b643188000b00018800
010b00000b60018800188000b6000b600188000b000188000b60018800188000b6000b6001880017600188000b600188000b0000b6000b6001880018800188000b60018800188000b6000b000188000b01318800
310b00000b0730c8530c8530c8530c8530c8530b0730c8530c8530c8530c8530c8530b0730c8530c8530c8530c8530c8530b0730c8330b0730c8530c8530c8530b60018800188001880018800188000b07318800
000b00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
610b00000b6130c8000b6230c8000b6130c8000b6230c8000b613188000b623188000b613188000b623188000b613188000b623188000b613188000b623188000b613188000b623188000b613188000b62318800
__music__
01 22424344
00 0c420844
00 0c420944
00 0c424a0a
00 0d42430b
00 0e400f44
00 1c401044
00 0e404f11
00 1c404f12
00 1d251352
00 1e1f1614
00 1d251554
00 1e1f1617
00 0c200821
00 0c200921
00 0c20210a
00 0d20210b
00 0e401844
00 0e401944
00 0e40591a
00 0e40591b
00 1d400f44
00 1e1f1044
00 1d404f11
00 231f4f12
00 0c200844
00 0c200944
00 0c20210a
00 0d20210b
00 24424344

