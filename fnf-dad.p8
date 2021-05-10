pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
--week 7 source code
--top secret hush hush

function _init()
	seed = flr(rnd(8000))*4
	baseseed = seed
	songid = 1
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
	synctime = 318
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
	--print(synctime,30,30,7)
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
			if step >= (((leftmap[1][1]+1)/32)*(synctime/2))-(notetime) then
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
	
	--center camera on duet (496)
	local _duetstart = ((496+1)/32)*(synctime/2)
	local _duetlength = ((14+1)/32)*(synctime/2)
	if step >= _duetstart and step < _duetstart+_duetlength then
		move_cam(0,-2)
	end
	
	--center camera on duet (816)
	local _duetstart = ((816+1)/32)*(synctime/2)
	local _duetlength = ((14+1)/32)*(synctime/2)
	if step >= _duetstart and step < _duetstart+_duetlength then
		move_cam(0,-2)
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
	if(btn(⬅️) or btn(⬅️,1)) press[1] = true
	if(btn(⬇️) or btn(⬇️,1)) press[2] = true
	if(btn(⬆️) or btn(⬆️,1) or btn(🅾️)) press[3] = true
	if(btn(➡️) or btn(➡️,1) or btn(❎)) press[4] = true
end

function game_draw()
	cls(1)
	pal()
	local lx = camx/2
	local ly = camy/2
	local llx = flr(camx/2)
	local lly = flr(camy/2)
	
	--ground
	fillp(0b1000111100101111.1)
	rectfill(-20,-20,148,148,0)
	fillp(█)
	circfill(lx+63,ly+481,400,5)
	fillp(▒)
	circfill(lx+63,ly+481+4,400,4)
	fillp(█)
	circfill(lx+63,ly+485+4,400,4)
	
	color(7)
	--print(step, 0, 0)
	--print(score,0, 8)
	--print(step-laststep,32,0)
	
	
	if hp > 0 then
		chars_draw()
		
		--curtains
		circfill(lx-63,ly-42,118,2)
		circfill(lx+128+63,ly-42,118,2)
		fillp(▒)
		circfill(lx-63-1,ly-42-1,118,8)
		circfill(lx+128+63+1,ly-42-1,118,8)
		fillp(█)
		local _nh = 128-noteheight
		
		--left side
		if downscroll == 0 then
		sspr(117,0,11,12,camx+4+(14*0),camy+_nh,11,12,true)
		sspr(116,12,12,11,camx+4+(14*1),camy+_nh,12,11,false,true)
		sspr(116,12,12,11,camx+4+(14*2),camy+_nh,12,11)
		sspr(117,0,11,12,camx+4+(14*3),camy+_nh,11,12)
		else
			sspr(117,0,11,12,camx+4+(14*0),camy+128-12-_nh,11,12,true)
			sspr(116,12,12,11,camx+4+(14*1),camy+128-12-_nh,12,11,false,true)
			sspr(116,12,12,11,camx+4+(14*2),camy+128-12-_nh,12,11)
			sspr(117,0,11,12,camx+4+(14*3),camy+128-12-_nh,11,12)
		end
		
		--right side
		if downscroll == 0 then
			if(press[1]) arrow_color(0)
			sspr(117,0,11,12,camx+113-14*3,camy+_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(116,12,12,11,camx+113-14*2,camy+_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(116,12,12,11,camx+113-14*1,camy+_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(117,0,11,12,camx+113-14*0,camy+_nh,11,12)
			pal()
		else
			if(press[1]) arrow_color(0)
			sspr(117,0,11,12,camx+113-14*3,camy+128-12-_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(116,12,12,11,camx+113-14*2,camy+128-12-_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(116,12,12,11,camx+113-14*1,camy+128-12-_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(117,0,11,12,camx+113-14*0,camy+128-12-_nh,11,12)
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
			palt(14,true)
			palt(0,false)
			sspr(115,23,13,9,_xx+3,camy+127-9)
			sspr(115,32,13,14,_xx-3-12,camy+127-14)
		else
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+128-(127-8),camx+63-42+84,camy+128-(127-2),3)
			rectfill(camx+63-42+1,camy+128-(127-7),camx+63-42+84-1,camy+128-(127-3),11)
			rectfill(camx+63-42,camy+128-(127-8),_xx,camy+128-(127-2),2)
			rectfill(camx+63-42+1,camy+128-(127-7),_xx,camy+128-(127-3),8)
			palt(14,true)
			palt(0,false)
			sspr(115,23,13,9,_xx+3,camy+128-9-(127-9))
			sspr(115,32,13,14,_xx-3-12,camy+128-17-(127-14))
		end
		
		--score
		if downscroll == 0 then
			print(tostr(score),camx+64-#tostr(score)*2,camy+4,7)
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

--hard difficulty
function init_beatmap_hard()
	
	--dad (start)
	map_add(leftmap,32*4,"0,2:4,0:6,1:8,2:12,0:14,3:16,2:18,3:20,0:22,1:24,2:28,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*5,"0,2:4,0:6,1:8,2:12,0:14,3:16,2:18,3:20,0:22,1:24,2:28,0:30,3")
	
	--dad
	map_add(leftmap,32*6,"0,1:4,0:6,3:8,1:12,2:16,1:20,0:22,0:24,3:26,3:28,3:30,3")
	
	--boyfriend
	map_add(rightmap,32*7,"0,1:4,0:6,3:8,1:12,2:16,1:20,0:22,0:24,3:26,3:28,3:30,3")
	
	--dad
	map_add(leftmap,32*8,"4,2:6,1:8,3:18,1:20,3:24,0:36,2:40,1:44,0:46,1:48,2:50,3:52,0:54,3:56,2")
	
	--boyfriend
	map_add(rightmap,32*10,"4,2:6,1:8,3:18,1:20,3:24,0:36,2:40,1:44,0:46,1:48,2:50,3:52,0:54,3:56,2")
	
	--dad
	map_add(leftmap,32*12,"0,1:2,0:4,3:6,2:8,1:12,0:18,2:20,3:22,1:24,2:28,0:32,0:36,1:40,3:44,1:48,2:52,3:56,1")
	map_add(leftmap,32*14,"2,1:4,3:6,2:8,0:10,2:12,1:16,0:17,3:18,0:20,1:22,0:24,2:26,3:28,1:34,0:36,3:38,1:40,2:42,3:44,1:46,3:48,0:50,1:52,0:54,3:56,2:60,3")
	
	--boyfriend
	--[[aAaAaaaAAA]] map_add(rightmap,32*15+16,"0,0:2,1:4,2:6,3:8,2:10,1:12,0:14,1")
	map_add(rightmap,32*16,"2,0:4,3:6,2:8,1:12,0:18,2:20,3:22,1:24,2:28,0:32,0:36,1:40,3:44,1:48,2:52,3:56,1")
	map_add(rightmap,32*18,"2,1:4,3:6,2:8,0:10,2:12,1:16,0:17,3:18,0:20,1:22,0:24,2:26,3:28,1:34,0:36,3:38,1:40,2:42,3:44,1:46,3:48,0:50,0:52,2:54,2:56,3:60,1")
	
	--dad
	map_add(leftmap,32*20,"0,2:4,0:6,1:8,2:12,0:14,3:16,2:18,3:20,0:22,1:24,2:28,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*21,"0,2:4,0:6,1:8,2:12,0:14,3:16,2:18,3:20,0:22,1:24,2:28,0:30,3")
	
	--dad
	map_add(leftmap,32*22,"0,1:4,0:6,3:8,1:12,2:16,1:20,0:22,0:24,3:26,3:28,3:30,3")
	
	--boyfriend
	map_add(rightmap,32*23,"0,1:4,0:6,3:8,1:12,2:16,1:20,0:22,0:24,3:26,3:28,3:30,3")
	
	--dad
	map_add(leftmap,32*24,"4,2:6,1:8,3:18,1:20,3:24,0:36,2:40,1:44,0:46,1:48,2:50,3:52,0:54,3:56,2")
	
	--boyfriend
	--[[aAaAaaaAAA]] map_add(rightmap,32*25+16,"0,0:2,1:4,2:6,3:8,2:10,1:12,0:14,1")
	map_add(rightmap,32*26,"4,2:6,1:8,3:18,1:20,3:24,0:36,2:40,1:44,0:46,1:48,2:50,3:52,0:54,3:56,2:60,1")
	
	--dad
	map_add(leftmap,32*28,"0,2:4,0:6,1:8,2:12,0:14,3:16,2:18,3:20,0:22,1:24,2:28,2")
	
	--boyfriend
	map_add(rightmap,32*29,"0,2:4,0:6,1:8,2:12,0:14,3:16,2:18,3:20,0:22,1:24,2:28,2")
	
	--dad
	map_add(leftmap,32*30,"0,1:4,0:6,3:8,1:12,2:16,1:20,1:24,1")
	
	--boyfriend
	map_add(rightmap,32*31,"0,1:4,0:6,3:8,1:12,2:16,1:20,1:24,1")
	
	
	music(0)
end

function init_beatmap()
	
	--dad
	map_add(leftmap,32*4,"0,2:4,0:8,2:12,0:14,3:16,2:18,3:20,0:24,2:28,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*5,"0,2:4,0:8,2:12,0:14,3:16,2:18,3:20,0:24,2:28,0:30,3")
	
	--dad
	map_add(leftmap,32*6,"0,1:4,0:6,3:8,1:16,1:20,0:22,0:24,3:26,3:28,3:30,3")
	
	--boyfriend
	map_add(rightmap,32*7,"0,1:4,0:6,3:8,1:16,1:20,0:22,0:24,3:26,3:28,3:30,3")
	
	--dad
	map_add(leftmap,32*8,"4,2:8,3:18,1:20,3:24,0:36,2:40,1:44,0:48,2:52,0:54,3:56,2")
	
	--boyfriend
	map_add(rightmap,32*10,"4,2:8,3:18,1:20,3:24,0:36,2:40,1:44,0:48,2:52,0:54,3:56,2")
	
	--dad
	map_add(leftmap,32*12,"2,0:4,3:8,1:12,0:18,2:20,3:24,2:28,0:32,0:36,1:40,3:44,1:48,2:52,3:56,0")
	map_add(leftmap,32*14,"2,1:4,3:8,0:12,1:16,0:20,1:24,2:26,3:28,2:34,0:36,3:40,2:42,3:44,2:48,0:52,2:56,3:60,3")
	
	--boyfriend
	--[[AAaaAAaa]]map_add(rightmap,32*15+16,"0,0:2,1:4,3:6,1:8,0:10,1:12,3:14,1")
	map_add(rightmap,32*16,"2,0:4,3:8,1:12,0:18,2:20,3:24,2:28,0:32,0:36,1:40,3:44,1:48,2:52,3:56,0")
	map_add(rightmap,32*18,"2,1:4,3:8,0:12,1:16,0:20,1:24,2:26,3:28,2:34,0:36,3:40,2:42,3:44,2:48,0:52,2:56,3:60,3")
	
	--dad
	map_add(leftmap,32*20,"0,2:4,0:8,2:12,0:14,3:16,2:20,0:24,2:28,0:30,3")
	
	--boyfriend
	map_add(rightmap,32*21,"0,2:4,0:8,2:12,0:14,3:16,2:20,0:24,2:28,0:30,3")
	
	--dad
	map_add(leftmap,32*22,"0,1:4,0:6,3:8,1:12,1:16,1:20,0:22,0:24,3:26,3:28,3:30,3")
	
	--boyfriend
	map_add(rightmap,32*23,"0,1:4,0:6,3:8,1:12,1:16,1:20,0:22,0:24,3:26,3:28,3:30,3")
	
	--dad
	map_add(leftmap,32*24,"4,2:6,1:8,3:18,1:20,3:24,0:36,2:40,1:44,0:46,1:48,2:50,3:52,0:54,3:56,2")
	
	--boyfriend
	--[[AAaaAAaa]]map_add(rightmap,32*25+16,"0,0:2,1:4,3:6,1:8,0:10,1:12,3:14,1")
	map_add(rightmap,32*26,"4,2:6,1:8,3:18,1:20,3:24,0:36,2:40,1:44,0:46,1:48,2:50,3:52,0:54,3:56,2")
	
	--dad
	map_add(leftmap,32*28,"0,2:4,0:8,2:12,0:14,3:16,2:18,3:20,0:24,2:28,2")
	
	--boyfriend
	map_add(rightmap,32*29,"0,2:4,0:8,2:12,0:14,3:16,2:18,3:20,0:24,2:28,2")
	
	--dad
	map_add(leftmap,32*30,"0,1:4,0:6,3:8,1:16,1:20,1:24,1")
	
	--boyfriend
	map_add(rightmap,32*31,"0,1:4,0:6,3:8,1:16,1:20,1:24,1")
	
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
	notetime = 1*60
	arrowcols = {2,1,3,4}
	lastrandom = -1
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
	hashit = false
	
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
			sspr(117,0,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(116,12,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(117,0,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(116,12,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
end

function arrows_draw_downscroll()
	for _t in all(lefttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
	end
	for _a in all(leftarrows) do
		if _a.dir < 4 then
			arrow_color(_a.dir)
			if _a.dir == 0 or _a.dir == 3 then
				sspr(117,0,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
			else
				sspr(116,12,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
			end
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(117,0,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
		else
			sspr(116,12,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
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
			chars[_chr].spx = 56
			chars[_chr].spy = 19
			chars[_chr].spw = 23
			chars[_chr].sph = 36
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 0
			chars[_chr].spy = 78
			chars[_chr].spw = 29
			chars[_chr].sph = 50
			chars[_chr].y = chars[_chr].sy + 3
		elseif _dir == 2 then
			chars[_chr].spx = 87
			chars[_chr].spy = 0
			chars[_chr].spw = 24
			chars[_chr].sph = 39
			chars[_chr].y = chars[_chr].sy - 3
		elseif _dir == 3 then
			chars[_chr].spx = 29
			chars[_chr].spy = 74
			chars[_chr].spw = 31
			chars[_chr].sph = 54
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
			chars[_chr].spy = 55
			chars[_chr].spw = 27
			chars[_chr].sph = 22
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 28
			chars[_chr].spy = 23
			chars[_chr].spw = 27
			chars[_chr].sph = 20
			chars[_chr].y = chars[_chr].sy + 4
		elseif _dir == 2 then
			chars[_chr].spx = 0
			chars[_chr].spy = 29
			chars[_chr].spw = 28
			chars[_chr].sph = 26
			chars[_chr].y = chars[_chr].sy - 4
		elseif _dir == 3 then
			chars[_chr].spx = 28
			chars[_chr].spy = 44
			chars[_chr].spw = 28
			chars[_chr].sph = 29
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
					chars[i].spx=80
					chars[i].spy=40
					chars[i].spw=24
					chars[i].sph=35
				else
					chars[i].sp = -2
					chars[i].spx=69
					chars[i].spy=75
					chars[i].spw=25
					chars[i].sph=35
				end
			else
				if flr(step/(synctime/8)) % 2 == 1 then
					chars[i].sp=-1
					chars[i].spx=0
					chars[i].spy=0
					chars[i].spw=28
					chars[i].sph=21
				else
					chars[i].sp=-2
					chars[i].spx=28
					chars[i].spy=0
					chars[i].spw=27
					chars[i].sph=23
				end
			end
		end
	end
	
	--girlfriend
	--[[
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
	]]--
	
end

function chars_draw()
	--girlfriend
	palt(0,false)
	palt(10,true)
	local lx = camx/4
	local ly = 0
	sspr(98,103,30,13,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22)
	if flr(step/(synctime/8)) % 2 == 1 then
		sspr(98,117,15,11,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13)
		sspr(98,117,15,11,lx-1+15+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13,15,11,true)
		sspr(55,0,13,15,lx+2+chars[3].x-16-12-1,ly+chars[3].y+12, 13, 15, true)
		sspr(55,0,13,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		sspr(104,57,24,23,lx+chars[3].x-flr(29/2)+4,ly+chars[3].y+4-flr(47/2)-1)
	else
		sspr(113,117,15,11,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13,15,11,true)
		sspr(113,117,15,11,lx-1+15+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2)+22+13)
		sspr(68,0,12,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		sspr(68,0,12,15,lx+2+chars[3].x-16-12,ly+chars[3].y+12, 12, 15, true)
		sspr(98,80,30,22,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(46/2))
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
			palt(11,true)
			if _c.sp == -2 then
				sspr(69,75,25,35,_c.x-flr(_c.spw/2),_c.y-57+4)
				sspr(64,111,23,17,_c.x-flr(_c.spw/2)-5,_c.y-57+35+4)
			elseif _c.sp == -1 then
				sspr(80,40,24,35,_c.x+1-1-flr(_c.spw/2),_c.y-56+4)
				sspr(64,111,23,17,_c.x-flr(_c.spw/2)-5,_c.y-57+35+4)
			elseif _c.sp == 1 or _c.sp == 3 then
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
			else
				if(_c.sp==0) sspr(56,19,23,36,_c.x-10,_c.y-17-_c.sph)
				if(_c.sp==2) sspr(87,0,24,39,_c.x-10-2,_c.y-17-_c.sph)
				sspr(64,111,23,17,_c.x-flr(_c.spw/2)-5,_c.y-57+35+4)
			end
		else
			if _c.sp == 3 then
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
			else
				if(_c.sp == -1)sspr(0,22,28,7,_c.x-flr(_c.spw/2),_c.y-7)
				if(_c.sp == -2) sspr(2,22,28,7,_c.x-flr(_c.spw/2),_c.y-7)
				if(_c.sp >= 0) sspr(2,22,28,7,_c.x-flr(_c.spw/2),_c.y-7)
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph-7,_c.spw,_c.sph)
			end
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
__gfx__
33333333333333222222233333333333333333322222222233333330001111aaaaaa000111aaaaaabbbbbbbbbbbbb00bbb00bbbbbbbbbbbbbbb0000005500000
33333333332222eeeee28033333333333333322eeeeeee28033333300655551111aa006555111aaabbbbbbbbbbb000bbbbb00bbbbbbbbbbbbbb0000056655000
3333333332eeeeeeee28880333333333333332eeeeeee2888033333116550000551a11655000511abbbbbbbbbb0d0bbb000d0bbbbbbbbbbbbbb0000056666500
333333332eeeee1eee2888033333333333332eeee6eee28880333331165051110651116505110651bbbbbbbbb0dd0000dddd0bbbbbbbbbbbbbb0055555666650
333333330000e16ee28888803333333333330cee16ee288888033331165055111051116505511051bbbbbbbbb0ddddddddd50bbbbbbbbbbbbbb0056666666665
33333331066606cee288888033333333333066606cee288888033331165016611051116501611051bbbbbbbbb05dd5ddd5550bbbbbbbbbbbbbb0056666666665
3333333166c666cce20888803333333333166c666c0e208888033331165500111651115500011651bbbbbbbbbb055d5555502bbbbbbbbbbbbbb0056666666665
33333316ccccc6cc1088880720003333316cc0cc6cce088888220001165550006551115555006551bbbbbbbbb0505555500ef2bbbbbbbbbbbbb0056666666665
33333316cc0cccc61000007721cc3333316cc0ccccc6000080771cc1165000055551115500055551bbbbbbbb055555500e0f02bbbbbbbbbbbbb0055555666650
333333111cc0ff6f0f6cc12f2310330003116c01fff0f6cc1f2f0101150111106551115011106551bbbbbbbb0055500efffe02bbbbbbbbbbbbb0000056666500
333333336c1f0ff20ff1f14423333016d036c1f0ff20ff11cf223331150511110551115051110551bbbbbbbbb0550e0000e082bbbbbbbbbbbbb0000056655000
33000331c12ff02f47fff00333330dd16d0c12ff02f47fff2223333005056611051a11505611051abbbbbbbbb0055e0008808e2bbbbbbbbbbbb0000005500000
306dd03112f774777f772723333300dd00012f774777f7722333333005000111051a11500011051abbbbbbbbb2ff5fff000f0e2b000bbbbbbbb0000055550000
01d16d2332777f77f772772333330d0d16022777f77f77276233333001101111651a00100110651abbbbbbbbbb2e02f0eefffe205010bbbbbbb0000566665000
01d0dd7232f777ff722267623333301610722f777ff72267723333300011000011aa0001000111aabbbbbbbbbbb2e02f07770f000550bbbbbbb0005666666500
010d602722222228866627723333330007273222228866667723333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2eef00000f011022bbbbbbb0056666666650
30160072222266e77e670ff23333332f772f26666e66e7202223333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22ee0770e20eeff2bbbbbb0056666666650
330007771cc777e7ee70f7f233333327777726077e7ee72ff433333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2e2eeeff2e0000f2bbbbbb0566666666665
333277f71ccc10000011777f1333332ff7740cc077ee702fff33333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2eeeeee0be0effe2bbbbbb0566566665665
3332f7ff2fff21001ccc1f7f12333332fff771110111cc177fc3333bbbbbbbbbb00bbbb0bbbbbbbbbbbbbbbbbbbbb2eeeee010e000ef2bbbbbb0055566665550
333322228eeee0f8112fcccc8233333224fffff2111cccc11113333bbbbbbbb000bbbbb00bbbbbbbbbbbbbbbbbbb00eeeeef00000fff2bbbbbb0000566665000
333333333333333333333333333333333222eeef00102f1cc123333bbbbbbb0dd0bbbb0000bbbbbbbbbbbbbbbbb0551efffff01005520bbbbbb0000566665000
33333326767e2e88128ee11282333333333267ee2f212feeee23333bbbbbbb0ddd0000ddd0bbbbbbbbbbbbbbbb055515efffdd10051150bbbbb0000555555000
333332ed7d8288828286666d2333333333333333222222233333333bbbbbbb05d5dddddd50bbbbbbbbbbbbbbb55551155ff55dd0010550bbbbbeee1111eeeeee
33332eee2228222228877d2d7e23333333333222eeeee2803333333bbbbbb0005555555550bbbbbbbbbbbbbb0555510555ff522d011550bbbbbee11ccc111eee
3333288e8882d6d62287e888e872333333332eeeeeee28880333333bbbbb0555055550000bbbbbbbbbbbbbb055555511155f12e2f11550bbbbbe1c1cccc1c1ee
33333277676dd00222ee8888276233333332eeee1eee28880333333bbbbb0550550000e22bbbbbbbbbbbbbb111155501155f52eee115550bbbb1ccc1ccc1c1ee
33333322222003333067777766233333333100e16ee288888033333bbbbbb05000eef0ff2bbbbbbbbbbbbbb011115555115ff002e111550bbbb11cc11111c1ee
33333333333333333302222222333333330c6606cee288008033333bbbbbb2250000ff00bbbbbbbbbbbbbbbb01111555110055112111550bbbbe1c11c1c11111
33333333333332222333333333333333331c6666cce280088022333bbbbbb2f200088088bbbbbbbbbbbbbbbbb0111151005555110111550bbbbe11c1c11cc1c1
3333333333332eeee223333333333333316c06c6cce2808802f20c0bbbbbb2e02f00f000bbbbbbbbbbbbbbbbb011110555555111001110bbbbbe1e1cccc1c11e
3333333333000eeeeee2233333333333316cc0cccc66000007721c1bbbbbb2e0e0eeff0e2bbbbbbbbbbbbbbbbb011055555111010b000bbbbbbeeee1111111ee
33333333316660eee1eee223333333331611cc00c6601f6c61f2033bbbbbbb2ee07700ee2bbbbbbbbbbbbbbbbbb01015551110e00bbbbbbbbbbe00eeeeeee000
333333331660c60061eeeee2333333331131cc100112f4f61c13333bbbbbbbb2ee0666116bbbbbbbbbbbbbbbbbbb01111111fdfe0bbbbbbbbbbee0000ee00220
333333316cc0cc60c0eee228033333333316c0fff2f0727ff233333bbbbbbbb22eeee16d1e2bbbbbbbbbbbbbbbbbb011100edd0e0bbbbbbbbbb000222002220e
333333311c6c0cc6c0e2288803333333331612727070277f2233333bbbbbb000eee221d1f2e22bbbbbbbbbbbbbbbb01100e09900bbbbbbbbbbb022222222000e
3333333316cc0cc6cc2888888033333332212f77007777726623333bbbb015155eeee00def2d62bbbbbbbbbbbbbbb01111009900bbbbbbbbbbbe02222222220e
33333331111101cccc880088803333224ff22000772277266623333bb005510550fff0122fffe2bbbbbbbbbbbbbbb01111011110bbbbbbbbbbbe0220022020ee
33333331322ff01616000888803332f777710d6107f882622233333b0155510555ffff0522ef250bbbbbbbbbbbbbb01110111110bbbbbbbbbbb0e0200022020e
333333332ffff06f0008888880332777f770661d60222684ff43333b05555511050f0052ee2e250bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0002000020000
333333332777f4200f161180023327474720dd06007e77e07773333b01115511055ff5d12e22000bbbbbbbbb00bbbbbbbbbbbbbbbbbbbbbbbbb0202000a00a00
33333330007777f4f416cc17f2332f4f222011d0d0000011c711333b11115510155f15dd121150bbbbbbbbb00bbbbb00bbbbbbbbbbbbbbbbbbb022270000000e
3333330d0d07f777227f1c7771133222ff21011110111c2cccc1333bb01115501150f0d0e01150bbbbbbbb0dd0bbbbb00bbbbbbbbbbbbbbbbbb0222707700720
33333010dd107ff22874242f21cc3333333333333333333333333333b01115511110f5dee01550bbbbbbbb0ddd00000dd0bbbbbbbbbbbbbbbbbe002070707000
3333306d0160227728f23222301c3333333333333332222233333333b01111010111f000011555bbbbbbbbb0ddddddddd0bbbbbbbbbbbbbbbbbee0227007000e
32220011d6d06622222333333300333333333333222eeee203333333bb011055500055550115550bbbbbbb050ddddddd50bbbbbbbbbbbbbbbbbeee0000000eee
32ff7006dd068866666233333333333333333222eeeee82880333333bb011555555555510115555bbbbbb05055d555550bbbbbbbbbbbbbbbb555555666666666
32f77f00002e7686266623333333333333332eeeeeeee28888033333bbb01511551111111011550bbbbb055055500000bbbbbbbbbbbbbbbbb555566000000000
2f77472f266eee76222623333333333333332eeee6ee828088033333bbb011111111111d111110bbbbbb055500e8ff8f2bbbbbbbbbbbbbbbb555601111111111
2ff772ff276777772ff22333333333333333000e16ee280888803333bbbb01111000edfe00000bbbbbb22250e008ee802bbbbbbbbbbbbbbbb556011111111111
2f747f22e20007772ff2333333333333333066600c1e200888823333bbbbb000011eddd000bbbbbbbbb2f050e88e80e88bbbbbbbbbbbbbbbb050111111111100
2f7722eeee2000cc177f133333333333333160c60cc18088882f0011bbbbb011110e990000bbbbbbbbbb2e0eff080e82bbbbbbbbbbbbbbbbb010111111111055
3222328eeee0e111cf777133333333333316c0ccc6c10200007721c1bbbbb011100099000bbbbbbbbbbb2eeef0ffeef2bbbbbbbbbbbbbbbbb010111111111055
333326767e2e80811177f113333333333316cc0c11c6006c110f2333bbbbb011100001110bbbbbbbbbbbb2e2f0000002bbbbbbbbbbbbbbbbb016011111100000
3332ed7d82888de8611111133333333333111c100f6200f6f1142333bbbbb011011111110bbbbbbbbbbbbb2eee6770ee2bbbbbbbbbbbbbbbb015601100000000
3333333333322222333333333333333333336c1200ff0f4ff2223333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2eef6760e2bbbbbbbbbbbbbbbba01566000000000
33333333322eeeee222233333333333333316132f0274727f2333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0ee22effe22bbbbbbbbbbbbbbbba01155666660000
3333333322eeeeeeee282333333333333331132f7477f88723333333bbbbbbbbbbbbbbbbbbbbbbbbbbbb0001eff2222110bbbbbbaaaaaaaaaaaa22aaaaaaaaaa
33333333000ee1eee2888033333333333223330007f2887262333333110000066555555bbbbbbbbbbbb055015efffff0111bbbbbaaaaaaaaaaaaa222aaaaaaaa
333333316660066e28888033333333322ff210d11022222672333333111111110665555bbbbbbbbbbb05550155ffddd00010bbbbaaaaaaaa222222442aaaaaaa
3333331066660c1e2888880333333327777d0d61600e762222333333111111111006555bbbbbbbbbb0555501152f55dddf2bbbbbaaaaaa244444222222aaaaaa
33333160cccc6c028880880333333277f47100060d0770ff03333333000111111106555bbbbbbbbb055155500152f55df222bbbbaaa2aa44444444444442aaaa
3333311c0ccccc02800888033333324ff4f601ddd10cc17721333333555011111116550bbbbbbbbb05111550116775502ff20bbbaa2aa24f444444444f442aaa
333333160011c66808888822333332f4f2ff201110cc1c1772133333555011111116110bbbbbbbbb011106001ff77600ee22500baa2a22fffffff4f4fff44aaa
3333316c100f61f0000882f233333322222f2800002f1cc111133333555011111106110bbbbbbbbbb01000d12fff665522255550a24244444f4f4ff4444442aa
333331112f0f1f0016c00771c13333326f22e2e8222ee1cc11333333000111111106110bbbbbbbbbbb101052f2ff665555555510a244424444444444444444aa
333331332747f20ff11cf2f01c03332ed7d828882ee8766d82333333000000011065110bbbbbbbbbbbb010022fe0111115555110aa22244444244444444444aa
33333332f777774777f04223300332eee7222222d2877227e233333300000000665110abbbbbbbbbbbb00002ee2501110011110baaa2422e2224e244444424aa
3333333277f7777277f222333333268e888820062287e888e223333300000666551110abbbbbbbbbbbbb1002ee251000010000bbaaa2222002ee20224ee442aa
33333333277fff882f27233333332767662033302ee8888826233333bbbbbbbbbbbbbbbbbbbbbbbbbbbbb1122e210eff01bbbbbbaa22242e00eee02e22e222aa
33332233020002282266723333332222222333306228888762333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb111221eeeee1bbbbbbaa2242ff44eff4f4422222aa
3222ff21001608622622223333333333333333330667676623333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb010010990ee0bbbbbbaa2442fffffffff222242aaa
32f777100d60d0ee7727703333333333333333333222222233333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00110099000bbbbbbb2aa240fff2082ff24244aa22
3277471010dd1000001c71133333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11100090110bbbbbbb22244400ff88ff2242442242
2f4f4f000111d011ccc11c113333bbbbbbbbbbbbbbbbb00bbbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11011111110bbbbbbba24444e2880042e42444442a
2ff42ff00101000112f1cc123333bbbbbbbbbbbbbbbb00bbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbbb00bbbbbbbbbbbbbbbbbbbbbbba224444288224ef2444442aa
22222f008000f8112feeee233333bbbbbbbbbbbbbbb0d50bb000d0bbbbbbbbbbbbbbbbbbbbbbbb00bbbbbbbbbbbbbbbbbbbbbbbba224440222224ff24444442a
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0ddd00dddd0bbbbbbbbbbbbbbbbbbbbbbb05d0bbb0000bbbbbbbbbbbbbbbbaa244200000244f24444442a
bbbbbbbbbbbbbbbbbbb000bbbbbbbbbbbbbbbbbbbbb0dd5dddd550bbbbbbbbbbbbbbbbbbbbbbb05dd000dddd0bbbbbbbbbbbbbbbaaa422effff000fe244442aa
bbbbbbbbbbbbbbbbb00d0bbbbbbbbbbbbbbbbbbbbb050555555550bbbbbbbbbbbbbbbbbbbbbb0505d5ddddd50bbbbbbbbbbbbbbbaa2ef2fffffffe2fffe22aaa
bbbbbbbbbbbbbbbbb0dd0bbbbb0bbbbbbbbbbbbbb050555555500bbbbbbbbbbbbbbbbbbbbbb0505555dddd550bbbbbbbbbaaaaaaaaaaaa2222aaaaaaaaaaaaaa
bbbbbbbbbbbbbbb000ddd0bbbb00bbbbbbbbbbbbb0550055000e2bbbbbbbbbbbbbbbbbbbbbb0550555555550bbbbbbbbbbaaaaaaaaaaaaa242222aaaaaaaaaaa
bbbbbbbbbbbbbb05505ddd0000d0bbbbbbbbbbbbb255500eeef0f2bbbbbbbbbbbbbbbbbbbbb0555000000e0bbbbbbbbbbbaaaaaaaaa222222444442aaaaaaaaa
bbbbbbbbbbbbbb0505555dddddd0bbbbbbbbbbbbb2250e000ff082bbbbbbbbbbbbbbbbbbbb22050e0e8fef8bbbbbbbbbbbaaaaaaa24444444444f442aaaaaaaa
bbbbbbbbbbbb2b055055555ddd50bbbbbbbbbbbbb2e00e0008e0ebbbbbbbbbbbbbbbbbbbbb2f05e000ef0febbbbbbbbbbbaaaaaa244444444f44f444aaaaaaaa
bbbbbbbbbbbb225505555555550bbbbbbbbbbbbbb2ef0ff00e000bbbbbbbbbbbbbbbbbbbbb2e000f08e808e8bbbbbbbbbbaaaaaa4ff44ff44fff44442aaaaaaa
bbbbbbbbbbbb2e500000055550bbbbbbbbbbbbbbbb2e22f0feeff2bbbbbbbbbbbbbbbbbbbbb2e0ffe080008bbbbbbbbbbbaaa2aa4444f4f4f44444442aaaaaaa
bbbbbbbbbbbb2e05ee0ee0000bbbbbbbbbbbbbbbbbbe2ef07770e2b0000bbbbbbbbbbbbbbbbb2e2e0efff2bbbbbbbbbbbbaaa2a224444444444444442aaaaaaa
bbbbbbbbbbbb2e00e00ffde22bbbbbbbbbbbbbbbbb2e2eee0000e2050560bbbbbbbbbbbbbbbb22e0000002bbbbbbbbbbbbaaa44244444444444444422aaaaaaa
bbbbbbbbbbbbb2e0ff00e0f02bbbbbbbbbbbbbbbbb2ee2ee0000f2101010bbbbbbbbbbbbbbbbb2e677700fbbbbbbbbbbbbaaa24242224442ee244ee42aaaaaaa
bbbbbbbbbbbbb2effff00000bbbbbbbbbbbbbbbbb2eeeeeef770f2122220bbbbbbbbbbbbbbbbb22ef670f02bbbbbbbbbbbaaaa22222e24e220e22fe2422aaaaa
bbbbbbbbbbbb2eeffffeee2bbbbbbbbbbbbbbbbb22eeeeeeeef2222eee2bbbbbbbbbbbbbbbbb2eee2fffff2bbbbbbbbbbbaaaaa2222e00ee402e2f2222aaaaaa
bbbbbbbbbbbb2eeef00ffe2bbbbbbbbbbbbbbbb0055eeee2222b2e222ff2bbbbbbbbbbbbbb0001eff2222220bbbbbbbbbbaaaaa2242ee0eff4f422224aaaaaaa
bbbbbbbbbb000eeee07702bbbbbbbbbbbbbbb0055511effffe112e2effe2bbbbbbbbbbbb0555111efffff0110bbbbbbbbbaaaaa2442ef4fffff4424442a2aaaa
bbbbbbbb005550eeef00f2bbbbbbbbbbbbbb055551150fffff012e2222e2bbbbbbbbbbb055511110fffddd0110bbbbbbbbaaaaaa42efff2082f224444442aaaa
bbbbbb05555511ef2e005602bbbbbbbbbbb0555551555ef5dd01222eeff2bbbbbbbbbb0555510011ff55dd2220bbbbbbbbaaaaaa40effff88ff42444442aaaaa
bbbbb0555555150ff226502e22bbbbbbbbb55155515550ff5ddd1152222bbbbbbbbbb05555555001167752e2e2bbbbbbbbaaa2a444002222222ef244442aaaaa
bbbb15555551055fff0502feee22bbbbbbb11155511155f55d00f000500bbbbbbbbbb05111555552667752ee220bbbbbbbaaa22444442888884ffe444442aaaa
bbbb551555511550ff0502f2eefe2bbbbbb01115550155ef5d500110000bbbbbbbbbbb011115552ff66660eee250bbbbbbaaa244444e02222224ff444442aaaa
bbbb011115501155f5501122f2f22bbbbbbb11115501550e00e0ef1110bbbbbbbbbbbbb0110502ffff66055e255550bbbbaaaa24444e00000222ff444422aaaa
bbbbb01115501155f55d2222e2e55bbbbbbb01115550150000eee011150bbbbbbbbbbbb0101d002ffe260555555510bbbbaaaaa444e2efff4400ef2442aaaaaa
bbbbb01111550555f002eee222e05bbbbbbbb11110000055550e0111550bbbbbbbbbbbbb005150ff22110115555510bbbbaaaaa24ff2fffffffe0ffe22aaaaaa
bbbbbb1111100000055eeee2e210bbbbbbbbb1110555555555501111550bbbbbbbbbbbbbb01512ee2550100111110bbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
bbbbbb011100555555552e211150bbbbbbbbb0115115551111100115550bbbbbbbbbbbbbbb0002e22500ee001110bbbbbbaaa111ef42ef222eff0ef22f211aaa
bbbbbbb110551555555502211550bbbbbbbbbb01111511111001b01550bbbbbbbbbbbbbbbb01122d01efdfe1000bbbbbbba11555552ef2fff2ee46666555511a
bbbbbbb0111111111111101115050bbbbbbbbb01111111000ee1bb000bbbbbbbbbbbbbbbbbb011100eeddde1bbbbbbbbbba1055622fff2fee22111110665051a
bbbbbbbb11111111100e01011500bbbbbbbbbbb0111010eeeee0bbbbbbbbbbbbbbbbbbbbbbbb0111e099000bbbbbbbbbbb150122ffff22ffe211111666060151
bbbbbbbb011110000e0e0001550bbbbbbbbbbbbb00000099000bbbbbbbbbbbbbbbbbbbbbbbb011100099000bbbbbbbbbbb156288822222eff000166611106551
bbbbbbbbb011100090000b0150bbbbbbbbbbbbbb01110099000bbbbbbbbbbbbbbbbbbbbbbbb011000111110bbbbbbbbbbb0560228820202ef255611111106550
bbbbbbbbb11100099000bbb00bbbbbbbbbbbbbbb11100055110bbbbbbbbbbbbbbbbbbbbbbbb110111111110bbbbbbbbbbb05611122111022fe22011111116150
bbbbbbbb011001111110bbbbbbbbbbbbbbbbbbb01101551111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55611111111022ff82011111116155
bbbbbbbb11011115511bbbbbbbbbbbbbbbbbbbb11011155110bbbbbbbbbbbbbbbbbbbbbbbbb00111111510bbbbbbbbbbbb556011111111028f82111111106155
bbbbbbbb10111155111bbbbbbbbbbbbbbbbbbb000155511110bbbbbbbbbbbbbbbbbbbbbbbb001111155110bbbbbbbbbbbb556011111100002882001111106155
bbbbbbb005115551110bbbbbbbbbbbbbbbbbbb05115111551bbbbbbbbbbbbbbbbbbbbbbbbb011111555110bbbbbbbbbbbb555601110000000222000011061555
bbbbbbb11555501111bbbbbbbbbbbbbbbbbbbb15551015550bbbbbbbbbbbbbbbbbbbbbbbbb051555111110bbbbbbbbbbbb555566600000000000000006615555
bbbbbbb11555101511bbbbbbbbbbbbbbbbbbb055111055510bbbbbbbbbbbbbbbbbbbbbbbb055155101151bbbbbbbbbbbbb555551166666666666666661555555
bbbbbb011111015110bbbbbbbbbbbbbbbbbbb15555015511bbbbbbbbbbbbbbbbbbbbbbbbb055511011551bbbbbbbbbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
bbbbbb115110015510bbbbbbbbbbbbbbbbbb011550011151bbbbbbbbbbbbbbbbbbbbbbbbb115510015510bbbbbbbbbbbbb555555666666666110000066555555
bbbbb011510b011510bbbbbbbbbbbbbbbbbb015510015510bbbbbbbbbbbbbbbbbbbbbbbb015510b015110bbbbbbbbbbbbb555566000000000111111660665555
bbbbb111150011111bbbbbbbbbbbbbbbbbbb15110b011510bbbbbbbbbbbbbbbbbbbbbbbb0511100111510bbbbbbbbbbbbb555601166611111111116611006555
bbbb0115510011150bbbbbbbbbbbbbbbbbb011550011155bbbbbbbbbbbbbbbbbbbbbbbb011510b011155bbbbbbbbbbbbbb556011111661111000161111106555
bbbb1155100115510bbbbbbbbbbbbbbbbbb111510015510bbbbbbbbbbbbbbbbbbbbbbbb0115500015555bbbbbbbbbbbbbb050111111116600555011111116550
bbb0111510011511bbbbbbbbbbbbbbbbbb0115110155510bbbbbbbbbbbbbbbbbbbbbbb01551110115110bbbbbbbbbbbbbb010111111111055555011111116110
bb01115110111550bbbbbbbbbbbbbbbbb0155111011511bbbbbbbbbbbbbbbbbbbbbbb015551010111510bbbbbbbbbbbbbb010111111111055555011111106110
bb011111000115110bbbbbbbbbbbbbbb011511010111510bbbbbbbbbbbbbbbbbbbbb0115110b0b011151bbbbbbbbbbbbbb016011111100000000111111106110
b0111100bb0111510bbbbbbbbbbbbbb0155110b0b011150bbbbbbbbbbbbbbbbbbbb0111110bbbb0011110bbbbbbbbbbbbb015601100000000000000011065110
011100bbbbbb001110bbbbbbbbbbbb0111110bbbbb001110bbbbbbbbbbbbbbbbbb0111100bbbbbbb000110bbbbbbbbbbbba0156600000000000000000665110a
0000bbbbbbbbbb000000bbbbbbbbb0000000bbbbbbbb00000bbbbbbbbbbbbbbbb000000bbbbbbbbbbbb0000bbbbbbbbbbba0115566666000000000666551110a
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111777111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111717111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111717111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111717111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111777111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191919191111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111191919191919111111111111111111111111111111
11111111155111111111155555511111111155551111111111551111111111111111111111115511111111915555559191911115555111111111155111111111
11111115566511111111156666511111111566665111111115665511111111111111111111556651111119195666659919191156666511111111566551111111
11111156666511111111156666511111115666666511111115666651111111111111111115666651111111915666659991911566666651111111566665111111
11111566665555511115556666555111156666666651115555566665111111111111111156666555551119555666655599195666666665111555556666511111
11115666666666511156656666566511156666666651115666666666511111111111111566666666651195665666656659915666666665111566666666651111
11115666666666511156666666666511566666666665115666666666511111111111111566666666651115666666666659156666666666511566666666651111
11115666666666511115666666665111566566665665115666666666511111111111111566666666651191566666666599956656666566511566666666651111
11115666666666511115666666665111155566665551115666666666511111111111111566666666651119566666666599195556666555111566666666651111
11111566665555511111566666651111111566665111115555566665111111111111111156666555551111956666665991911156666511111555556666511111
11111156666511111111156666511111111566665111111115666651111111111111111115666651111119195666659919191156666511111111566665111111
11111115566511111111115555111111111555555111111115665511111111111111111111556651111111919555599191911155555511111111566551111111
11111111155111111111111111111111111111111111111111551111111111111111111111115511111111191919191919111111111111111111155111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191919191111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119191111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111222211111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111124222211111111111111111111111111111111111111111111111111111111111
11111111111222222222222222222222222222222222222222222222222222222444442222222222222222222222222222222222222222222222111111111111
11111111111111111111111111111111111111111111111111111111124444444444f44211111111111111111111111111111111111111111111111111111111
22222222222222222224442222244442222222222222222222222222244444444f44f44422222222222222222222222222222222222222222222222222222222
11111111111111111442111244444ff21111111111111111111111114ff44ff44fff444421111111111111111111111111111111111111111111111111111111
22222222222222222242222444f4fff22222222222222222222222224444f4f4f444444422222222222222222222222222222222222222222222222222222222
1111111111111111112224444ffff424422221112111111111111212244444444444444421111111111111111111111111111111111111111111111111111111
22222222222222222224444444224444244444242222222222222442444444444444444222222222222222222222222222222222222222222222222222222222
1111111111111111244444482d82444444422242111111111111124242224442ee244ee421111111111111111111111111111111111111111111111111111111
222222222222222244442228dd8d2244442222222222222222222222222e24e220e22fe242222222222222222222222222222222222222222222222222222222
11111111111111124442dd0822802444444211111111111111111112222e00ee402e2f2222111111111111111111111111111111111111111111111111111111
22222222222222224440ddd8208d4444444422222222222222222222242ee0eff4f4222242222222222222222222222222222222222222222222222222222222
111111111111112474440dde20e04444444421111111111111111112442ef4fffff4424442121111111111111111111111111111111111111111111111111111
22222222222222247744d00e00e0444444422222222222222222222242efff2082f2244444422222222222222222222222222222222222222222222222222222
11111111111111147064888e81e8844444444442222111111111111140effff88ff4244444211111111111111111111111111111111111111111111111111111
22222222222222244d044d7e77e6224444444444422222222222222444002222222ef24444222222222222222222222222222222222222222222222222222222
111111111111114449da4d780887624444444442111111111111122444442888884ffe4444421111111111111111111111111111111111111111111111111111
2222222222222244494a407870872444444444222222222222222244444e02222224ff4444422222222222222222222222222222222222222222222222222222
1111111111111444494a47d800824444444442211111111111111124444e00000222ff4444221111111111111111111111111111111111111111111111111111
222222222222222444a42978d011244444444442222222222222222444e2efff4400ef2442222222222222222222222222222222222222222222222222222222
111111111111111244421009aa0012444424444422222222222222224ff2fffffffe0ffe22222222222222222222221111111111111111111111111111111111
22222222222222220244210002800024442222422222222222222111ef42ef222eff0ef22f211222222222222222222222222222222222222222222222222222
22222222222222221124421111888800222222222222222222211555552ef2fff2ee466665555112222222222222222222222222222222222222222222222222
2222222222222222110221111108880002222222222222222221055622fff2fee221111106650512222222222222222222222222222222222222222222222222
22222222222222220111111101002201102222222222222222150122ffff22ffe211111666060151222222222222222222222222222222222222222222222222
22222222222222222011000000022001112222222222222222156288822222eff000166611106551222222222222222222222222222222222222222222222222
222222222222222220010200000880201022222222222222220560228820202ef255611111106550222222222222222222222222222222222222222222222222
2222222222222222200022211118807912222222222222222205611122111022fe22011111116150222222222222222222eeeeeee28022222222222222222222
222222222222222201122220110280d792222222222222222255611111111022ff8201111111615522222222222222222eeeeeee288802222222222222222222
222222222222222211122200110080867d2222222222222222556011111111028f821111111061552222222222222222eeee6eee288802222222222222222222
222222222222222201122011118080206022222222221110005560111111000028820011111061500011122222222220cee16ee2888880222222222222222222
22222222222222220110001110888800d2222222211155560055560111000000022200001106155006555111222222066606cee2888880222222222222222222
222222222222222220100000088828800222222115000556115555666000000000000000066155511655000511222166c666c0e2088880222222222222222222
2222222222222222a00a22888828288022222215601150561155555116666666666666666155555116505110651216cc0cc6cce0888882200022222222222222
22222222222222229aaa08888882282ddddddd15011550561155555566000001111000006655555116505511051d16cc0ccccc6000080771cc22222222222222
222222222222222299aa02888880001ddddddd150116105611555566066111111111111660665551165016110000d116c01fff0f6cc1f2f01022222222222222
22222222222dddd000995728800d007ddddddd15611000551155560011661111111111661100655115500011016d0d6c1f0ff20ff11cf22ddddd222222222222
2222dddddddddddd0ddd700000d7000ddddddd15555000551155560111116100000016111110655115555000dd16d0c12ff02f47fff222ddddddddddddd22222
ddddddddddddddddd6671101006700d5d5d5d5155601110511055611111110555555011111116551155000500dd00012f774777f7722dddddddddddddddddddd
ddddddddddddddddd007d0d00000005d5d5d5d15501115051101161111111055555501111111611115011100d0d16022777f77f772762ddddddddddddddddddd
ddddddddddd5d5d5d50d0d0d000110d5d5d5d5d150116505110116011111105555550111111061111505111001610722f777ff72267725d5d5d5dddddddddddd
dddd5d5d5d5d5d5d5d00d0d00000105d5d5d5d515011000511011601111111000000111111106111150561105000727d222228866667725d5d5d5d5d5d5ddddd
d5d5d5d5d5d5d5d5d5d00000d5d001555555555156011001000115601100000000000000110651111500011052f772f26666e66e720222d5d5d5d5d5d5d5d5d5
5d5d5d5d5d5d5d5d5d5001055550005555555555111000100050115660000000000000000665110001001106527777726077e7ee72ff4d5d5d5d5d5d5d5d5d5d
d5d5d5d5d5d5555555500115555001555555555555555555555011155666000000000066655111000010001112ff7740cc077ee702fff5555555d5d5d5d5d5d5
5d5d555555555555550001055550115555555555555555555555555555555555555555555555555555555555552fff771110111cc177fc5555555555555d5d5d
555555555555555555001155555010555555555555555555555555555555555555555555555555555555555555224fffff2111cccc1111555555555555555555
55555555555555555501105555511055555555555555555555555555555555555555555555555555555555555555222eeef00102f1cc12555555555555555555
5555555555555555550000555500010555555555555555555555555555555555555555555555555555555555555555267ee2f212feeee2555555555555555555
555555555555555550010055500000055555555555555555555555555555555555555555555555555555555555526767e2e88128ee1128255555555555555555
5555555555555555500100555005000555555555555555555555555555555555555555555555555555555555552ed7d8288828286666d2555555555555555555
555555555555555500105055550500005555555555555555555555555555555555555555555555555555555552eee2228222228877d2d7e25555555555555555
55555555555555550010505555055000055555555555555555555555555555555555555555555555555555555288e8882d6d62287e888e872555555555555555
555555555555555000055555555555555555555555555555555555555555555555555555555555555555555555277676dd00222ee88882762555555555555555
55555555555555500055555555555555555555555555555555555555555555555555555555555555555555555552222200555506777776625555555555555555
55555555555555000555555555555555555555555555555555555555555555555555555555555555555555555555555555555550222222255555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555500000005555555555511115555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555000808888005552333311ccc1113333333333333333333333333333333333333333333333333333333333333333333333335555555555555555555555
55555550800088888805588bb1c1cccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555550880000800805588b1ccc1ccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555555000008000055588b11cc11111c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555555080070870805588bb1c11c1c11111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
55555550088000800880588bb11c1c11cc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb35555555555555555555555
5555555080888888000052333131cccc1c1133333333333333333333333333333333333333333333333333333333333333333333335555555555555555555555
55555550000000000555555555551111111555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555

__sfx__
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
000200000f860200201b0101b0301b020150100b01006010030200002022000260002100019000110000e0000a000080000800006000040000400004000030000100000000010000000000000000000000000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000e0700e070178001780023600236000e0700e070008000080000000178000e0700e0702360000000000000000000000000000e0700e070178001780000000236000e0700e07000000000000000000000
010a00000a0700a070178001780023600236000a0700a070000000080000800178000c0700c0702360000000000000000000000000000c0700c070178001780000000236000c0700c07000000000000000000000
010a00000a0500a0550a0500a05000000000000a0500a05000000000000a0500a05000000000000a0500a05000000000000a0500a05000000000000a050000000a0500a05000000000000a0500a0500000000000
010a00000c0500c0550c0500c05000000000000c0500c05000000000000c0500c05000000000000c0500c05000000000000c0500c05000000000000c050000000c0500c05000000000000c0500c0500000000000
010a00000e0500e0550e0500e05000000000000e0500e05000000000000e0500e05000000000000e0500e05000000000000e0500e05000000000000e050000000e0500e05000000000000e0500e0500000000000
010a00000e0500e0550e0500e05511050110550e0500e05510050100550e0500e0550e0500e0550e0500e0550e0500e0550e0500e05511050110550e0500e05510050100550e0500e0550e0500e0550e0500e055
490a0000006550000000655178000c673236000065517800006551780000655178000c673236000065517800006550080000655178000c673236000065517800006550080000655000000c673236000065523600
490a00000c0530000000655178000c673236000c05317800006551780000655178000c67323600006551780000655008000c053178000c6732360000655178000c0530080000655000000c673236000065523600
0d0a0000151501515023100231000e150171001115000100151501515023100231000e1501710011150111501315013150151501515013150001001115023100131501315023100231000e150001001115000100
0d0a0000215702157023500235001a570175001d57000500215702157023500235001a570235001d5701d5701f5701f57021570215701f570185001d570235001f5701f57023500235001a570185001d57000500
0d0a00001a1401a1401a1401a1401514015140131401314511140111401114011145101401014010140101450e1400e1400e1400e1450e1400e1450e1400e1450e1400e1450e1400e1450e1400e1450e1400e145
0d0a00002655026550265502655021550215501f5501f5551d5501d5501d5501d5551c5501c5501c5501c5551a5501a5501a5501a5551a5501a5551a5501a5551a5501a5551a5501a5551a5501a5551a5501a555
0d0a00001a1001a1001a1001a100111401114511140111400e1400e1400e1400e1400e1400e1400e1400e1400e1000e1000e1400e140101411014010140101400c1400c1400c1400c1400c1400c1400c1400c140
0d0a00001a1001a1001a1001a10015140151401514015140131401314013140131451314013145151401514515140151451614016140151401514013140131401514015140151401514015140151401514015140
0d0a00001a5001a5001a5001a5001d5401d5451d5401d5401a5401a5401a5401a5401a5401a5401a5401a5400e5000e5001a5401a5401c5411c5401c5401c5401854018540185401854018540185401854018540
0d0a00001a5001a5001a5001a500215402154021540215401f5401f5401f5401f5451f5401f54521540215452154021545225402254021540215401f5401f5402154021540215402154021540215402154021540
0d0a0000111300000016140000001314000000111400000013140131401314013140151401514015140151400e1000e100151400e100131400e10011140111001314013140131401314016140161401614016140
0d0a0000151301514015140151401314013140131401314011140111401114011140101401014010140101400e1400e1400e1400e1400c1400c1400c1400c1400714007140071400714007140071400714007140
0d0a0000151001510015140151001314013100111401310013140111001514011100131401314013140131451314513145151400c100131400c10011140071001314007100151400710013140131401314013140
0d0a00000080000800151401780013140236001114017800131400080015140178001314023600111401780015140008001614017800151402360013140008001514015140151401514011140111401114011140
490a00000c05300000006551780000655236000c053178000c67317800006551780000655236000c6731780000655008000c05317800006552360000655178000c6730080000655000000c673236000c67323600
0d0a0000008000080017800178002360023600178001780000800008001780017800236002360017800178002954029540285402854029540295402b5402b5402d5402d5402b5402b54029540295402854028540
0d0a0000285402854022540005001f540005001d540005001f5401f5401f5401f540215402154021540215401a5001a500215401a5001f5401a5001d5401d5001f5401f5401f5401f54022540225402254022540
0d0a0000215302154021540215401f5401f5401f5401f5401d5401d5401d5401d5401c5401c5401c5401c5401a5401a5401a5401a540185401854018540185401354013540135401354013540135401354013540
0d0a0000215002150021540215001f5401f5001d5401f5001f5401d500215401d5001f5401f5401f5401f5451f5451f54521540185001f540185001d5401f5001f5401f500215401f5001f5401f5401f5401f540
0d0a0000005000050021540235001f540235001d540235001f5401850021540235001f540235001d540235002154018500225402350021540235001f54018500215402154021540215401d5401d5401d5401d540
0d0a0000285402854028540285401d5401d5451d5401d5401a5401a5401a5401a5401a5401a5401a5401a5400e5000e5001a5401a5401c5411c5401c5401c5401854018540185401854018540185401854018540
0d0a00001a5001a5001a5001a500215402154021540215401f5401f5401f5401f5451f5401f54521540215452154021545225402254021540215401f5401f540215402154021540215401d5401d5401d5401d540
0d0a0000151401514023100231000e140171001114000100151401514023100231000e14017100111401114013140131401514015140131400010011140231001314013140231002310013140131402310000100
0d0a0000215502155023500235001a550235001d55018500215502155023500235001a550235001d5501d5501f5501f55021550215501f550185001d550235001f5501f55023500235001f5501f5502350000500
0d0a00001a1301a1301a1301a1301513015130131301313511130111301113011135101301013010130101350e1300e1300e1300e1350e1300e1300e1300e1350e1300e1300e1300e1350e1000e1000e1000e100
0d0a00002654026540265402654021540215401f5401f5451d5401d5401d5401d5451c5401c5401c5401c5451a5401a5401a5401a5451a5401a5401a5401a5451a5401a5401a5401a5451a5001a5000e5000e500
490a00000c0530000000655178000c673236000c05317800006551780000655178000c67323600006551780000655008000c053178000c6732360000655178000c0530080000655000000c673000000c6730c673
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000080000800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236002360000000
010a00000207002070178001780023600236000a0000a000000000080000800178000c0000c0002360000000000000000000000000000c0000c000178001780000000236000c0000c00000000000000000000000
010a00000c05300800178001780023600236001780017800008000080017800178002360023600178001780000800008001780017800236002360017800008000080023600000002360023600236000000000000
__music__
00 080e4d4d
00 090e4d4d
00 080e4d4d
00 090e4d4d
00 0a0f104d
00 0b0f4d11
00 0c0f124d
00 0d0f4d13
00 0a0f144d
00 0b0f154d
00 0c0f4d16
00 0d0f4d17
00 0a1c184d
00 0b1c194d
00 0c1c1a56
00 0d1c1b1d
00 0a1c581e
00 0b1c591f
00 0c1c5a20
00 0d1c5b21
00 0a0f104d
00 0b0f4d11
00 0c0f124d
00 0d0f4d13
00 0a0f144d
00 0b0f151d
00 0c0f4d22
00 0d0f4d23
00 080f244d
00 090f4d25
00 080f264d
00 09284d27
00 41423e3f

