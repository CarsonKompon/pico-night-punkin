pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--week 7 source code
--top secret hush hush

function _init()
	seed = flr(rnd(8000))*4
	baseseed = seed
	songid = 2
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
	synctime = 385 --382
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
	--print(synctime,50,50,7)
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
	
	if true then --potential check for spikes
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
	
	--center camera on duet (544)
	local _duetstart = ((544+1)/32)*190
	local _duetlength = ((68+1)/32)*190
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
	--sun
	circfill(92,14,5,9)
	fillp(▒)
	circfill(92,14,8,9)
	--gradient
	fillp(▤)-- ▤ <- y | b -> ▒
	circfill(lx+63,ly+960+8,920,2)
	fillp(█)
	circfill(lx+63,ly+960+48,940,2)
	--ground
	circfill(lx+63,ly+481,400,13)
	fillp(▒)
	circfill(lx+63,ly+485,400,5)
	fillp(█)
	circfill(lx+63,ly+485+4,400,5)

	
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
			palt(14,true)
			palt(0,false)
			sspr(115,30,13,9,_xx+3,camy+127-9)
			sspr(79,47,15,15,_xx-5-11,camy+127-14)
		else
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+129-(127-8),camx+63-42+84,camy+129-(127-2),3)
			rectfill(camx+63-42+1,camy+129-(127-7),camx+63-42+84-1,camy+129-(127-3),11)
			rectfill(camx+63-42,camy+129-(127-8),_xx,camy+129-(127-2),2)
			rectfill(camx+63-42+1,camy+129-(127-7),_xx,camy+129-(127-3),8)
			palt(14,true)
			palt(0,false)
			sspr(115,30,13,9,_xx+3,camy+129-9-(127-9))
			sspr(79,47,15,15,_xx-5-11,camy+129-18-(127-14))
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
function init_beatmap_hard()
	
	--pico
	map_add(leftmap,32,"6,2:8,3:10,2:14,0:18,0:22,2:24,3:26,2:30,0")
	map_add(leftmap,64,"6,2:8,3:10,2:14,0:18,0:22,2:24,3:26,2:30,0")
	
	--boyfriend
	map_add(rightmap,64+32,"6,2:8,3:10,2:14,0:18,0:22,2:24,3:26,2:30,0")
	map_add(rightmap,128,"6,2:8,3:10,2:14,0:18,0:22,2:24,3:26,2:30,0")
	
	--pico
	map_add(leftmap,128+32,"2,2:4,3:6,0:8,3:10,0:12,1:18,3:20,0:22,2:24,3:26,0:28,1")
	map_add(leftmap,128+64,"2,3:4,0:6,3:8,2:10,0:12,1:18,2:20,3:22,0:24,3:26,0:28,1")
	
	--boyfriend
	map_add(rightmap,192+32,"2,2:4,3:6,0:8,3:10,0:12,1:18,3:20,0:22,2:24,3:26,0:28,1")
	map_add(rightmap,192+64,"2,3:4,0:6,3:8,2:10,0:12,1:18,2:20,3:22,0:24,3:26,0:28,1")
	
	--pico
	map_add(leftmap,256+32,"2,0:4,3:6,2:8,2:10,3:12,1:14,3:16,2:18,3:19,0:20,3:22,2:24,0,4:28,1,3")
	map_add(leftmap,256+64,"2,3:4,1:6,2:8,3:10,1:12,2:14,3:16,0:18,0:20,3:22,3:24,2,4:28,1,4")
	
	--boyfriend
	map_add(rightmap,320+32,"2,0:4,3:6,2:8,2:10,3:12,1:14,3:16,2:18,3:19,0:20,3:22,2:24,0,4:28,1,3")
	map_add(rightmap,320+64,"0,2:2,3:4,1:6,2:8,3:10,1:12,2:14,3:16,0:18,0:20,3:22,3:24,2,4:28,1,4")
	
	--pico
	map_add(leftmap,384+32,"2,2:4,3:6,0:8,3:10,0:11,3:12,1:18,2:20,0:22,3:24,3:26,0:27,3:28,1:34,3:36,0:38,0:40,2:42,0:43,3:44,1:50,2:52,3:54,0:56,3:58,0:59,3:60,1")
	
	--boyfriend
	map_add(rightmap,480,"2,2:4,3:6,0:8,3:10,0:11,3:12,1:18,2:20,0:22,3:24,3:26,0:27,3:28,1:34,3:36,0:38,0:40,2:42,0:43,3:44,1:50,2:52,3:54,0:56,3:58,0:59,3:60,1")
	
	--duet
	map_add(rightmap,480+64,"0,2,3:6,3:8,1:12,3:16,0:18,2:20,0:22,3:24,1,3:32,2,3:38,3:40,1:44,3:48,0:50,2:52,0:54,3:56,2:58,2:60,0:62,0")
	map_add(leftmap,480+64,"2,2:4,3:6,0:8,3:10,0:11,3:12,1:18,2:20,0:22,3:24,3:26,0:27,3:28,1:34,3:36,0:38,0:40,2:42,0:43,3:44,1:50,2:52,3:54,0:56,3:58,0:59,3:60,1")
	
	--boyfriend
	map_add(rightmap,544+64,"2,2:4,3:6,0:8,3:10,0:11,3:12,1:18,2:20,0:22,3:24,3:26,0:27,3:28,1:34,3:36,0:38,0:40,2:42,0:43,3:44,1:50,2:52,3:54,0:56,3:58,0:59,3:60,1")
	
	--pico
	map_add(leftmap,672,"2,0:4,3:6,2:8,2:10,3:12,1:14,3:16,2:18,3:19,0:20,3:22,2:24,0,4:28,1,3")
	map_add(leftmap,672+32,"2,3:4,1:6,2:8,3:10,1:12,2:14,3:16,0:18,0:20,3:22,3:24,2,4:28,1,4")
	
	--boyfriend
	map_add(rightmap,736,"2,0:4,3:6,2:8,2:10,3:12,1:14,3:16,2:18,3:19,0:20,3:22,2:24,0,4:28,1,3")
	map_add(rightmap,736+32,"0,2:2,3:4,1:6,2:8,3:10,1:12,2:14,3:16,0:18,0:20,3:22,3:24,2,4:28,1,4")
	
	music(0)
end

function init_beatmap()
	
	--pico
	map_add(leftmap,32*1,"6,2:8,3:10,2:14,0:18,0:22,2:24,3:26,2:30,0")
	map_add(leftmap,32*2,"6,2:8,3:10,2:14,0:18,0:22,2:24,3:26,2:30,0")
	
	--boyfriend
	map_add(rightmap,32*3,"6,2:8,3:10,2:14,0:18,0:22,2:24,3:26,2:30,0")
	map_add(rightmap,32*4,"6,2:8,3:10,2:14,0:18,0:22,2:24,3:26,2:30,0")
	
	--pico
	map_add(leftmap,32*5,"2,2:8,3:10,0:12,1:18,3:24,3:26,0:28,1")
	map_add(leftmap,32*6,"2,3:8,2:10,0:12,1:18,2:24,3:26,0:28,1")
	
	--boyfriend
	map_add(rightmap,32*7,"2,2:8,3:10,0:12,1:18,3:24,3:26,0:28,1")
	map_add(rightmap,32*8,"2,3:8,2:10,0:12,1:18,2:24,3:26,0:28,1")
	
	--pico
	map_add(leftmap,32*9,"2,0:4,3:8,2:12,1:16,2:18,3:19,0:20,3:24,0,4:28,1,3")
	map_add(leftmap,32*10,"2,3:4,1:8,3:10,1:14,3:16,0:18,0:20,3:22,3:24,2,4:28,1,4")
	
	--boyfriend
	map_add(rightmap,32*11,"2,0:4,3:8,2:12,1:16,2:18,3:19,0:20,3:24,0,4:28,1,3")
	map_add(rightmap,32*12,"2,3:4,1:8,3:10,1:14,3:16,0:18,0:20,3:22,3:24,2,4:28,1,4")
	
	--pico
	map_add(leftmap,32*13,"2,2:8,3:10,0:11,3:12,1:18,2:24,3:26,0:27,3:28,1")
	map_add(leftmap,32*14,"2,3:8,2:10,0:11,3:12,1:18,2:24,3:26,0:27,3:28,1")
	
	--boyfriend
	map_add(rightmap,32*15,"2,2:8,3:10,0:11,3:12,1:18,2:24,3:26,0:27,3:28,1")
	map_add(rightmap,32*16,"2,3:8,2:10,0:11,3:12,1:18,2:24,3:26,0:27,3:28,1")
	
	--duet
	map_add(rightmap,32*17,"0,2,3:6,3:8,1:12,3:16,0:20,0:22,3:24,1,3")
	map_add(rightmap,32*18,"0,2,3:6,3:8,1:12,3:16,0:18,2:20,0:22,3:24,2:26,2:28,0:30,0")
	map_add(leftmap,32*17,"2,2:8,3:10,0:11,3:12,1:18,2:24,3:26,0:27,3:28,1")
	map_add(leftmap,32*18,"2,3:8,2:10,0:11,3:12,1:18,2:24,3:26,0:27,3:28,1")
	
	--boyfriend
	map_add(rightmap,32*19,"2,3:8,3:10,0:11,3:12,1:18,2:24,3:26,0:27,3:28,1")
	map_add(rightmap,32*20,"2,3:8,2:10,0:11,3:12,1:18,2:24,3:26,0:27,3:28,1")
	
	--pico
	map_add(leftmap,32*21,"2,0:4,3:8,2:12,1:16,2:18,3:19,0:20,3:24,0,4:28,1,3")
	map_add(leftmap,32*22,"2,3:4,1:8,3:10,1:14,3:16,0:18,0:20,3:22,3:24,2,4:28,1,4")
	
	--boyfriend
	map_add(rightmap,32*23,"2,0:4,3:8,2:12,1:16,2:18,3:19,0:20,3:24,0,4:28,1,3")
	map_add(rightmap,32*24,"2,3:4,1:8,3:10,1:14,3:16,0:18,0:20,3:22,3:24,2,4:28,1,4")
	
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
	notetime = 1*45
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
				poke(0x5f43)
				hashit=true
				
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
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+128-(_t.y+(_t.len*12)),arrowcols[_t.dir+1])
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
			chars[_chr].spx = 30
			chars[_chr].spy = 89
			chars[_chr].spw = 33
			chars[_chr].sph = 36
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 92
			chars[_chr].spy = 65
			chars[_chr].spw = 36
			chars[_chr].sph = 28
			chars[_chr].y = chars[_chr].sy + 2
		elseif _dir == 2 then
			chars[_chr].spx = 0
			chars[_chr].spy = 91
			chars[_chr].spw = 29
			chars[_chr].sph = 35
			chars[_chr].y = chars[_chr].sy - 3
		elseif _dir == 3 then
			chars[_chr].spx = 95
			chars[_chr].spy = 93
			chars[_chr].spw = 33
			chars[_chr].sph = 35
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
					chars[i].spx=64
					chars[i].spy=96
					chars[i].spw=30
					chars[i].sph=32
				else
					chars[i].sp = -2
					chars[i].spx=59
					chars[i].spy=62
					chars[i].spw=31
					chars[i].sph=33
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
	if flr(step/(synctime/8)) % 2 == 1 then
		sspr(115,0,13,15,lx+2+chars[3].x-16-12,ly+chars[3].y+12, 12, 14, true)
		sspr(115,0,13,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		sspr(85,0,29,47,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2))
	else
		sspr(115,15,12,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		sspr(115,15,12,15,lx+2+chars[3].x-16-12,ly+chars[3].y+12, 12, 14, true)
		sspr(55,0,29,46,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(46/2))
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
			palt(12,true)
			--if _c.sp == -1 or _c.sp == -2 or _c.sp == 3 or _c.sp == 4 then
			--	sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-10-_c.sph,_c.spw,_c.sph)
			--	if _c.sp == -2 then sspr(0,118,24,10,_c.x+2-flr(_c.spw/2),_c.y-10)
			--	else sspr(0,118,24,10,_c.x-flr(_c.spw/2),_c.y-10) end
			--else
			sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
			--end
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
__gfx__
3333333333333322222223333333333333333332222222223333333aaaaaaaaaaaa2222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa22aaaaaaaaaaa0001111aaaaaa
33333333332222eeeee28033333333333333322eeeeeee280333333aaaaaaaaaaaaa242222aaaaaaaaaaaaaaaaaaaaaaaaaaaaa222aaaaaaaaa00655551111aa
3333333332eeeeeeee28880333333333333332eeeeeee2888033333aaaaaaaaa222222444442aaaaaaaaaaaaaaaaaaaaaa222222442aaaaaaaa116550000551a
333333332eeeee1eee2888033333333333332eeee6eee2888033333aaaaaaa24444444444f442aaaaaaaaaaaaaaaaaaa244444222222aaaaaaa1165051110651
333333330000e16ee28888803333333333330cee16ee28888803333aaaaaa244444444f44f444aaaaaaaaaaaaaaaa2aa44444444444442aaaaa1165055111051
33333331066606cee288888033333333333066606cee28888803333aaaaaa4ff44ff44fff44442aaaaaaaaaaaaaa2aa24f444444444f442aaaa1165016611051
3333333166c666cce20888803333333333166c666c0e20888803333aaa2aa4444f4f4f44444442aaaaaaaaaaaaaa2a22fffffff4f4fff44aaaa1165500111651
33333316ccccc6cc1088880720003333316cc0cc6cce08888822000aaa2a224444444444444442aaaaaaaaaaaaa24244444f4f4ff4444442aaa1165550006551
33333316cc0cccc61000007721cc3333316cc0ccccc6000080771ccaaa44244444444444444422aaaaaaaaaaaaa244424444444444444444aaa1165000055551
333333111cc0ff6f0f6cc12f2310330003116c01fff0f6cc1f2f010aaa24242224442ee244ee42aaaaaaaaaaaaaa22244444244444444444aaa1150111106551
333333336c1f0ff20ff1f14423333016d036c1f0ff20ff11cf22333aaaa22222e24e220e22fe2422aaaaaaaaaaaaa2422e2224e244444424aaa1150511110551
33000331c12ff02f47fff00333330dd16d0c12ff02f47fff2223333aaaaa2222e00ee402e2f2222aaaaaaaaaaaaaa2222002ee20224ee442aaa005056611051a
306dd03112f774777f772723333300dd00012f774777f7722333333aaaaa2242ee0eff4f422224aaaaaaaaaaaaaa22242e00eee02e22e222aaa005000111051a
01d16d2332777f77f772772333330d0d16022777f77f77276233333aaaaa2442ef4fffff4424442a2aaaaaaaaaaa2242ff44eff4f4422222aaa001101111651a
01d0dd7232f777ff722267623333301610722f777ff722677233333aaaaaa42efff2082f224444442aaaaaaaaaaa2442fffffffff222242aaaa00011000011aa
010d602722222228866627723333330007273222228866667723333aaaaaa40effff88ff42444442aaaaaaaaaa2aa240fff2082ff24244aa22a000111aaaaaaa
30160072222266e77e670ff23333332f772f26666e66e7202223333aaa2a444002222222ef244442aaaaaaaaaa22244400ff88ff2242442242a006555111aaaa
330007771cc777e7ee70f7f233333327777726077e7ee72ff433333aaa22444442888884ffe444442aaaaaaaaaa24444e2880042e42444442aa11655000511aa
333277f71ccc10000011777f1333332ff7740cc077ee702fff33333aaa244444e02222224ff444442aaaaaaaaaa224444288224ef2444442aaa116505110651a
3332f7ff2fff21001ccc1f7f12333332fff771110111cc177fc3333aaaa24444e00000222ff444422aaaaaaaaaa224440222224ff24444442aa116505511051a
333322228eeee0f8112fcccc8233333224fffff2111cccc11113333aaaaa444e2efff4400ef2442aaaaaaaaaaaaa244200000244f24444442aa116501611051a
33333326767e2e88128ee112823333333222eeef00102f1cc123333aaaaa24ff2fffffffe0ffe22aaaaaaaaaaaaaa422effff000fe244442aaa115500011651a
333332ed7d8288828286666d23333333333267ee2f212feeee23333aaa111ef42ef222eff0ef22f211aaaaaaaaaa2ef2fffffffe2fffe22aaaa115555006551a
33332eee2228222228877d2d7e2333333277767288ee8e777233333a11555552ef2fff2ee46666555511aaaa1112ff2eff22efff2f22fe11aaa115500055551a
3333288e8882d6d62287e888e87233332ee27728882ee7777722333a1055622fff2fee22111110665051aa11555555eff2ff4ef46666655511a115011106551a
33333277676dd00222ee8888276233332ee82882e62287eeeee8233150122ffff22ffe211111666060151a10555624ff2feef2411110066051a115051110551a
333333222220033330677777662333327882222e0008ee888882233156288822222eff0001666111065511501522eff41ffef1111166610615111505611051aa
33333333333333333302222222333332776776233302ee8888262330560228820202ef255611111106550155628822221eff21111661111065111500011051aa
333333333333322223333333333333332222223333066777776233305611122111022fe220111111161500556022220210ef42016111111065000100110651aa
3333333333332eeee2233333333333333333333333302222222333355611111111022ff8201111111615505161111111052ff226111111106500001000111aaa
3333333333000eeeeee223333333333333333333222222233333333556011111111028f8211111110615555161111111052ff82211111110655eee1111eeeeee
33333333316660eee1eee2233333333333333222eeeee2803333333556011111100002882001111106155551611111111028f88211111110655ee11ccc111eee
333333331660c60061eeeee23333333333332eeeeeee28880333333555601110000000222000011061555555161110000002888200011106155e1c1cccc1c1ee
333333316cc0cc60c0eee228033333333332eeee1eee288803333335555666000000000000000066155555555160000000002220000000615551ccc1ccc1c1ee
333333311c6c0cc6c0e2288803333333333100e16ee28888803333355555116666666666666666155555555555166000000000000006661555511cc11111c1ee
3333333316cc0cc6cc28888880333333330c6606cee288008033333555555660000000110000066555555555555551111111111111115555555e1c11c1c11111
33333331111101cccc88008880333333331c6666cce280088022333555566011111111111111660665555555555666666666666666666555555e11c1c11cc1c1
33333331322ff0161600088880333333316c06c6cce2808802f20c0555600111111111111116611006555555566000000000000000000665555e1e1cccc1c11e
333333332ffff06f0008888880333333316cc0cccc66000007721c1555601111111000000161111106555555601111111111111116661106555eeee1111111ee
333333332777f4200f161180023333331611cc00c6601f6c61f2033055611111110555555011111116550556011111111111111166111110655ccccccccccccc
33333330007777f4f416cc17f23333331131cc100112f4f61c13333011611111110555555011111116110050111111111100006611111111050ccccccccccccc
3333330d0d07f777227f1c77711333333316c0fff2f0727ff233333011601111110555555011111106110010111111111055550111111111010ccccccccccccc
33333010dd107ff22874242f21cc3333331612727070277f2233333011601111111000000111111106110010111111111055550111111111010ccccccccccccc
3333306d0160227728f23222301c333332212f77007777726623333011560110000000000000011065110016011111100000000001111110610ccccccccccccc
32220011d6d0662222233333330033224ff22000772277266623333a0115660000000000000000665110a015601100000000000000001106510ccccccccccccc
32ff7006dd06886666623333333332f777710d6107f882622233333a0111556660000000000666551110aa0155660000000000000000066510accccccccccccc
32f77f00002e76862666233333332777f770661d60222684ff43333000005500000000055550000eeeeeea0111556666000000006666655110accccccccccccc
2f77472f266eee7622262333333327474720dd06007e77e07773333000056655000000566665000eeeee000eeeeeeecccccccccccccccccccccccccccccccccc
2ff772ff276777772ff2233333332f4f222011d0d0000011c711333000056666500005666666500eeeee0bb00eeeeecccccc8cccc0d505dddd0ddddd0ccccccc
2f747f22e20007772ff2333333333222ff21011110111c2cccc1333055555666650056666666650eeeee0bbbb00eeeccccc111cc001505150101111100cccccc
2f7722eeee2000cc177f133333333333226770000e8222eeccce233056666666665056666666650ee0000bbbbb00eeccc0dddddddddddddddddddddddddd0ccc
3222328eeee0e111cf777133333333332e77e7828882ee8676e2223056666666665566666666665ee0bb0bbbbbb0eecc0d11111111111111111111111111d0cc
333326767e2e80811177f11333333332eee22228222e28767227ee2056666666665566566665665ee0bbbb00bbbb0ec80000000000000000000000000000008c
3332ed7d82888de861111113333333328ee88882e000087e8888e82056666666665055566665550ee0bbb0bb0bbb00c20d81050501111111111111111118d02c
332eee22282222e877227e823333333327767720333302ee8888272055555666650000566665000000bbb0bb00bbb0cc001105050114999411100001111111cc
3278ee8882d6d228e888827233333333322222333333306676776230000566665000005666650000bbbb0b00bb0b00cc001111111111111111011101111111cc
327782222d00308ee888826233333333333333333333332222222330000566550000005555550000bbbb0bb00bb0b0cc111111111111111111000001111111cc
3327777722033062288876623333333333333333333222223333333000005500000cccccccccccce0bb000bbb0bb00cc0b13bbbb3bbbb3bbbb0bb30bb3bb31cc
3332222222333306667762223333333333333333222eeee203333333cccccccccccccccccccccccee0b0b0bbbb0000c00b13bbbb3bbbb3bbbb0bb30bb3bb31cc
3333333333333332222223333333333333333222eeeee82880333333ccccccccccccccccccccccceee00bbb0bb0b0ec00b13bbbb3bbbb3bbbb01010bb3bb31cc
3333333333322222333333333333333333332eeeeeeee28888033333ccccccccccccccccccccccceeeee00b000b0eec00000000000000000000101000000000c
33333333322eeeee222233333333333333332eeee6ee828088033333ccccccccccccccccccccccceeeeeee00000eeec01111111111111111101110111111110c
3333333322eeeeeeee282333333333333333000e16ee280888803333ccccccccc0000ccc022ccccccccccccccccccccc0000000000000000000000000000000c
33333333000ee1eee288803333333333333066600c1e200888823333ccccccccc099900004922cccccccccccccccccc0010101111111111110111011111111cc
333333316660066e2888803333333333333160c60cc18088882f0011ccccccccc0999999049992cccccccccccccccccccccccccccccccccccccccccccccccccc
3333331066660c1e28888803333333333316c0ccc6c10200007721c1ccccccccc099999a9999992cccccccccccccccccccc000cccccccccccccccccccccccccc
33333160cccc6c0288808803333333333316cc0c11c6006c110f2333ccccccccc04999aaaaa9992ccccccc11cccccccccc049900cccccccccccccccccccccccc
3333311c0ccccc02800888033333333333111c100f6200f6f1142333ccccccccc04999a2229a9a42cccc0d001ccccccccc09999900c22ccccccccccccccccccc
333333160011c668088888223333333333336c1200ff0f4ff2223333ccccccc00044a92eee29aa22cc00dd001ccccccccc099999990492cccccccccccccccccc
3333316c100f61f0000882f23333333333316132f0274727f2333333ccccccc0999aa2e00fe292e0c010d0d50ccccccccc0499999994992ccccccccccccccccc
333331112f0f1f0016c00771c13333333331132f7477f88723333333ccccccc049992e0ff0fe2e020010d06d0ccccccccc049999aa999992cccccccccccccccc
333331332747f20ff11cf2f01c0333333223330007f2887262333333ccccccc044992fffff0fef021100dd06d0cccccc00049a92229a9992cccc000000cccccc
33333332f777774777f04223300333322ff210d11022222672333333cccccccc04442fffff00f0e250110d5000ccccc09999992eee29a9aa2cc066066600cccc
3333333277f7777277f2223333333327777d0d61600e762222333333ccccccccc0442fffff0400f20111000dd0ccccc0499992e00fe299a92006d606ddd000cc
33333333277fff882f27233333333277f47100060d0770ff03333333cccccccccc0027efff0ff0f211d0111000ccccc044992e0ff0fe2992100ddd0ddd606d0c
3333223302000228226672333333324ff4f601ddd10cc17721333333ccccccccc000077efffff4fe2d0111110ccccccc04492ffff0ffe22e1001dd0ddd606d00
3222ff210016086226222233333332f4f2ff201110cc1c1772133333cccccccc07650022eeffffee20022100ccccccccc0222fffff0ffee01e01d101dd60d100
32f777100d60d0ee7727703333333322222f2800002f1cc111133333cccccccc060650bb222222220f2ee2ccccccccccc02eefffff00ff0e0e011101dd105100
3277471010dd1000001c7113333333326f22e2e8222ee1cc11333333ccccccc20500003bbbbb30c2ff2220cccccccccccc2ef2ffff0f00e2c00111011110110c
2f4f4f000111d011ccc11c113333332ed7d828882ee8766d82333333cccccc2ef0d0d023bbbbb0c2ffef20cccccccc000c22282fff0f40f2ccc00101111000cc
2ff42ff00101000112f1cc12333332eee7222222d2877227e2333333cccccc2fffe00ff2bbbbb300f22f20ccccccc00d102e28822ffffff2ccccc000000ccccc
22222f0080000f8112feeee23333268e888820062287e888e2233333ccccc2ef2ee2fee23bbbbb11e2eee0cccccc01d0102f222ff222fffe2cccccc00ccccccc
3333327767d62e82e8e7776223332767662033302ee8888826233333ccccc2fff2e2ee23333311100e2110cccccc00d5222e2133222222222ccccccccccccccc
333332ee277288822ee77777e2232222222333306228888762333333cccc02f2e22222333111222002110ccccccc0d02fee221333333330402cccccccccccccc
333332ee82882d6622877eeeee623333333333330667676623333333ccc012e222100111122244442000ccccccccc02fffe2210bb30300400a22cccccccccccc
333332782222d200308ee88882723333333333333222222233333333ccc01102000cc022244400442ccccccccccccc2fff22e200000022009a0a2ccccccccccc
3333332776720033302ee8882762ccccccccccccccccccccccccccccccc000cccccc2024444002442222ccccccccccc2fffe2202220f9902009a2ccccccccccc
3333333222223333306677776623ccccccccccccccccccccccccccccccccccccccc29040004402000a0a22cccccccc222ff2e20204009902220082cccccccccc
3333333333333333330022222233cccccccccccccccccccccccccccccccccccccc2990099a0000980909082cccccc27222ee2990000c00022222272ccccccccc
cccccccccccccccccccccccccccccccccccccccc00ccccccccccccccccccccccc22009aa0008099000200822ccccc27722222002880cc0ffffff772ccccccccc
ccccccccccccccccccccccccccccccccccccccc09900ccccccccccccccccccccc2782000aa0000ff02222272cccccc2f770000000070cc000002222ccccccccc
ccccccccc22ccccccccccccccccccccccccccc04999900c02cccccccccccccccc2f0222200800000ff77772cccccccc22fff77777700cccccccccccccccccccc
cccccccc09922ccccccccccccccccccccccccc049999990492cccccccccccccccc2f702222770ccc000000ccccccccccc222200000cccccccccccccccccccccc
cc000000099992cccccccccccccccccccccccc0499999990992cccccccccccccccc2ff777700ccccccccccccccccccccccccc0000ccccccccccccccccccccccc
c099999999aa9a2ccccccccccccccccccccccc044999aaa99992cccccccccccccccc000000cccccccccccccccccccccccccc0999900c0222cccccccccccccccc
09999999aaaaa992cccccccccccccccccccc00044a9a99aaa992cccccccccccccccccccccccccccccccccccccccccccccccc0999999049992ccccccccccccccc
009999a99222a9200cccccccccccccccccc049999a992229aa992ccccccccccccccccccc0000cccccccccccccccccccccccc09999999099992cccccccccccccc
c09999a900ee22e02cccccccccccccccccc044999922ffe29a9a2cccccccccccccccccc0999000c02ccccccccccccccccccc0499999aaaa9942ccccccccccccc
cc049a90ee0feef02cccccccccccccccccc0442992effffe29222cccccccccccccccccc09999990092cccccc111ccccccccc04999a9999aa992ccccccccccccc
ccc0492efff0fff0e2cccccccccccccccccc00f22eff00ffe2ef2cccccccccccccccccc0999999909922ccc1001cccccccccc44aa992222aa9a2cccccccccccc
c009992fff000fe002ccccccccccccccccccc02f2fffff0ffeff2cccccccccccccccccc049999a999992ccc10060ccccccc0004a992eeee299a2cccccccccccc
04999992f2f04040ff2cccccccccccccccccc02e2fffff00f0ef0cccccccccccccccccc049aa9aaaa99a2c0616d0cccccc04999992e00ffe2922cccccccccccc
0444422ff82ffffffe2ccccccccccccccccccc000e22ff0700e02cccccccccccccccc00044a922229aaaa00dddd0cccccc0449992ff0f0ffe202cccccccccccc
c0042feef88222fe22cccc000c111cccccc220d000282f074f00cccccccccccccccc00999992eeee29992010dd6d0ccccc0444442fffff0ffe00cccccccccccc
ccc00fee000ffe22ccccc0dd60001cccccc2e200dd0882ff22e200cccccccccccccc0449992ef00fe29220110dd0d0ccccc02224efffff00f002cccccccccccc
ccccc0e06610220ccccc00dd65001cccc22eff2d0002ff22f2e06600ccccccccccccc044992f0ff0fe2e0111100000cccccc2fe2e22fff0f00e2cccccccccccc
cccccc0105d00b0cccc010dd60550cc22effff21100222ffff16dd660000cccccccccc00042fffff0fe001d101110cccccccc2ee2882ff0f20f2cccccccccccc
cccccc00d6d50bb0cc0100dd6650cc2ffff2fe210100bb2220dd66dd60110cccccccccc0002ffff00004edd011110ccccccccc22f888222ff2fe2ccccccccccc
cccccc3222510ebb001110dd6060cc2efee2ee222203bbbb06dd60ddd0fe2ccccccccc07500efff0400f2d10d110cccccccccc0322000effffff2ccccccccccc
cccccc2fff22febb0111110d0600cc22e2e2ee2fe2033bbb06d50dd5d0ff2ccccccc22260d07eff0ff0f22010e0cccccccccc033b05650222222cccccccccccc
ccccc02ffff2e03301110010dd60ccc2222222ee2cc033bb06d50dd0d02f2cccccc2efe5600777effff4fe20ee0cccccccccc03300d5d500cccccccccccccccc
cccc012ff2e200003000f0110dd0cccccccc2222ccc0333300dddd5dd02ef2cccc2efff200022222efffee20f22ccccccccc0332220d1d0b0cc000000000cccc
ccc0112fff2e22220ff2ee00000cccccccccccccccc033001000dd0d602e22ccc2eff2f22222bbbb222222ee2f2cccccccc0332eee20110bb001111111060ccc
ccc0112fee22244440f2ee20ccccccccccccccccccc00220011000d660dd2cccc2ffff2e2ff23bbbb30c2e00ee2cccccccc0312effe2002200100000010d0ccc
cccc012f2244440040ee220cccccccccccccccccccc02441010111006000ccccc02e22ee2fe033bbbbb00011e20cccccccc0112ffffe22f20111111110d66011
ccccc00222440002440f2ccccccccccccccccccccc02444100001111002ccccc01222e0002203bbbbbb31111110ccccccccc012ff2fe2fe200ddddd110d55501
ccccccc0244420024422ccccccccccccccccccccc222200101d201110092cccc01000200111333333111010000ccccccccccc2efff22e220ff00dd000dd00011
ccccccc2024442200000cccccccccccccccccccc220009901000900090922ccc000ccccc00031111122220ccccccccccccccc2ff2e2e2224000e00010dd0d0cc
cccccc2900044000900902ccccccccccccccccc209200009a0209920020082cccccccccccc0122222404402ccccccccccccc222ee2222244400eed010d0d0ccc
cccccc29090020f99090902ccccccccccccccc2702299aa0000400222222822cccccccccc22224440024442222cccccccc2221122442200e00909d0110dd0ccc
cccccc2000a00c0f22090882cccccccccccccc2f722222aa88000ff00222072ccccccccc200000442022000a0a2cccccc2990009994209928090900110d0cccc
ccccc220aa000cc0022222072cccccccccccccc2f70222228070c00fff77722ccccccc22990999022000980909222ccc229900000900099020020820000ccccc
cccc2f0000288700f00207772ccccccccccccccc2f772220070cccc000000cccccccc270a9000aa009099200200882c2720099aa0000f00022222022cccccccc
cccc2f70222807000ffff722ccccccccccccccccc22f777770ccccccccccccccccccc2f8009aa000090ff022228882c2f0220000080700ff00222772cccccccc
ccccc22f7777770cc00000ccccccccccccccccccccc220000cccccccccccccccccccc2f72200aa0870000ffff77772c2f702222220070c00fffff22ccccccccc
ccccccc2200000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc2f7222002770ccc00000000ccc2f7722200770cccc00222ccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc22f7777700cccccccccccccccc2ff7777700ccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000ccccccccccccccccccc2222000ccccccccccccccccccccccc
__label__
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999955999999999955555599999999955559999999999559999999999999999999999995599999999995555559999999995555999999999955999999999
99999995566599999999956666599999999566665999999995665599999999999999999999556659999999995666659999999956666599999999566559999999
99999956666599999999956666599999995666666599999995666659999999999999999995666659999f99995666659999999566666659999999566665999999
9999956666555559999555666655599995666666665999555556666599999999999999995666655555f9ff555666655599995666666665999555556666599999
99995666666666599956656666566599956666666659995666666666599999999999999566666666659995665666656659995666666665999566666666659999
99995666666666599956666666666599566666666665995666666666599999999999999566666666659995666666666659956666666666599566666666659999
99995666666666599995666666665999566566665665995666666666599999999999999566666666659999566666666599956656666566599566666666659999
99995666666666599995666666665999955566665559995666666666599999999999999566666666659999566666666599995556666555999566666666659999
99999566665555599999566666659999999566665999995555566665999999999999999956666555559999956666665999999956666599999555556666599999
9999995666659999999995666659999999956666599999999566665999999999999999999566665999999999566665ff99999956666599999999566665999999
99999995566599999999995555999999999555555999999995665599999999999999999fff5566599999999995555999f9999955555599999999566559999999
99999999955999999999999999999999999999999999999999559999999999999999fff99999559999999999999999999ff99999999999999999955999999999
999999999999999999999999999999999999999999999999999999999999999999ff9999999999999999999999999999999ff999999999999999999999999999
999999999999999999999999999999999999999999999999999999999999999fff99999999999999999999999999999999999ff9999999999999999999999999
999999999999999999999999999999fff999999999999999999999999999fff9999999999999999999999999999999999999999ff99999999999999999999999
99999999999999999999999999ffff999ff9999999999999999999999fff999999999999999999999999999999999999999999999ff999999999999999999999
9999999999999999999999ffff999999999ff99999999999999999fff99999999999999999999999999999999999999999999999999ff9999999999999999999
999999999999999999ffff999999999999999f99999999999999ff9999999999999999999999999999999999999999999999999999999ff99999999999999999
99999999999999ffff99999999999999999999ff999999999fff99999999999999999999999999999999999999999999999999999999999ffff9999999999999
999999999fffff99999999999999999999999999ff9999fff999999999999999999999999999999999999999999999999999999999999999999ffff999999999
99999ffff999999999999999999999999999999999ffff9999999999999999999999999999999999999999999999999999999999999999999999999ffff99999
9ffff9999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999999999999999999fffff
f9999999999999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999fffff99999999999999999999999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999999999999fffff999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999999999999999999fff9999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999222299999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999924222299999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999222222444442999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999924444444444f44299999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999244444444f44f44499999999999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999999994ff44ff44fff444429999999999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999992994444f4f4f444444429999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999292244444444444444429999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999442444444444444444229999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999924242224442ff244ff429999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999922222f24f220f227f242299999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999992222f00ff402f272222999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999992242ff0f77474222249999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999992442f74777774424442929999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999942f777208272244444429999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999940f777788774244444299999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999929444002222222f724444299999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999922444448eeeee477f4444429999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999244444f08828824774444429999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999924444f00000822774444229999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999444f2f7774400f72442999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999247727777777f077f22999999999999999999999999999999999999999999999999999999
99999999999999999999900000000000999999999999999999999111f742f7222f770f7227211999999999999999999999999999999999999999999999999999
99999999999999999990000000000000099999999999999999911555552f727772ff466665555119999999999999999999999999999999999999999999999999
999999999999999999000000000000000999999999999999999105562277727ff221111106650519999999999999999999999999999999999999999999999999
9999999999999999990000006777777600999999999999999915012277772277f211111666060159999999999999999999999999999999999999999999999999
999999999999999999000677777777777609999999999999991562eee82282f77000166611106559999999999999999999999999999999999999999999999999
99999999999999999000677777777777770999999999999999056022ee20202f7255611111106559999999999999999999999999999999999999999999999999
99999999999999999000777777777777770999999999999999056111221110227f82011111116159999999999999999999999999999999999999999999999999
999999999999999990007777777777777709999999999999995561111111102877e2011111116159999999999999999999999999999999999999999999999999
9999999999999999900077777777777777099999999999999955601111111102e7e2111111106159999999999999999999999999999999999999999999999999
99999999999999999000677777777777760999999999911100556011111100002ee2001111106150011199999999999999222222222999999999999999999999
99999999999999999000067776000677600999999911155560555601110000000222000011061550655511199999999922eeeeeee28099999999999999999999
9999999999999999900000000006000000999999115000556155556660000000000000000661555165500051199999992eeeeeee288809999999999999999999
999999999999999999000006600006600990707156011505615555511666666666666666615555516505110651999992eeee6eee288809999999999999999999
999999999999999999000007077707000900060750115505615555556600000001100000665555516505511051999990cee16ee2888880999999999999999999
9999999999999999999000000000000009060660501161056155556601111111111111166066555165016110519999066606cee2888880999999999999999999
9999999999999999997700060000060000d0606056110005515556001111111111111166110065515500011651444166c666c0e2088880999999999999999999
9999999999999999900600077666770000d0d000056005555155560111111100000016111110655155550065514416cc0cc6cce0888882200999999999999999
9999999999944004760000077777776010d00105055500055105561111111055555501111111655155000555514416cc0ccccc6000080771c444999999999999
999944444444000006004407777777701000566005601110510116111111105555550111111161115011106550004116c01fff0f6cc1f2f01444444444499999
4444444444440000000011677777776011010000100111505101160111111055555501111110611150511105016d046c1f0ff20ff11cf2244444444444444444
4444444444440000000010167777760401011001010116505101160111111100000011111110611150561100dd16d0c12ff02f47fff222444444444444444444
44444444444400000000000100000004011111000101100051011560110000000000000011065111500011000dd00012f774777f772244444444444444444444
4444444444444000000000010000000100010000016011001040115660000000000000000665110010011060d0d16022777f77f7727624444444444444444444
444444444444400000000111000000000000111014444444444011155666000000000066655111044444444401610722f777ff72267724444444444444444444
44444444444444000000010100000000010041114444444444444444444444444444444444444444444444444000757422222886666772444444444444444444
444444444444444000000001044440001014444444444444444444444444444444444444444444444444444442f772f26666e66e720222444444444444444444
4444444444444444000001100044000000044444444444444444444444444444444444444444444444444444427777726077e7ee72ff44444444444444444444
444444444444444440011100004400000001444444444444444444444444444444444444444444444444444442ff7740cc077ee702fff4444444444444444444
4444444444444444400000000144000000014444444444444444444444444444444444444444444444444444442fff771110111cc177fc444444444444444444
444444444444444440000000014000000001444444444444444444444444444444444444444444444444444444224fffff2111cccc1111444444444444444444
44444444444444441000000001400000000144444444444444444444444444444444444444444444444444444444222eeef00102f1cc12444444444444444444
4444444444444444100000000140000000014444444444444444444444444444444444444444444444444444444444267ee2f212feeee2444444444444444444
44444444444444441110000011400000011011444444444444444444444444444444444444444444444444444444277767288ee8e77724444444444444444444
44444444444444400001000001400000000001444444444444444444444444444444444444444444444444444442ee27728882ee777772244444444444444444
44444444444444000000000001440000000001444444444444444444444444444444444444444444444444444442ee82882e62287eeeee824444444444444444
44444444444444000000000114444000000011444444444444444444444444444444444444444444444444444427882222e0008ee88888224444444444444444
4444444444444400000001144444444400111444444444444444444444444444444444444444444444444444442776776244402ee88882624444444444444444
44444444444444411111144444444444444444444444444444444444444444444444444444444444444444444442222224444066777776244444444444444444
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
44444444400000000444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444000000000044444444411114444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444400000000000442333311ccc1113333333333333333333333333333333333333333333333333333333333333333333333334444444444444444444444
44444440000000000004488bb1c1cccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444440007777777004488b1ccc1ccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444440007777777004488b11cc11111c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444440007770777004488bb1c11c1c11111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444444000007000044488bb11c1c11cc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
4444444440070077004442333131cccc1c1133333333333333333333333333333333333333333333333333333333333333333333334444444444444444444444
44444444444444444444444444441111111444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

__sfx__
2d0200200d07304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073
000200000f860200201b0101b0301b020150100b01006010030200002022000260002100019000110000e0000a000080000800006000040000400004000030000100000000010000000000000000000000000000
010200200407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073
010100001c3501e3502035022350233502635027350293502b3502c3502a35026350203501c350143500e350083500635004350033500435006350073500a3500e35011350103500c35004350023500135002350
010c00000c073000030c623000000c673000030c073000030c623000000c623000030c6730000311600000030c073000030c623000000c673000030c073000030c623000000c073000030c673000030562300003
010100200055200552005520055200552005520055200552005520055200552005520055200552005520055200552005520055200552005520055200552005520055200552005520055200552005520055200552
010100200055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550
010400000c07300073000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070
6d0c000000502005020050200502005020050206572005020457200502065720050200502005020657200502005020050206572005020050200502065720050204572005020657200502005020050212d7200502
2b0c00000050000500005000050000500005001e5300c5001c530185001e5301850018500185001e5301850018500185001e5301850018500185001e530185001c530185001e5301850018500185001253012535
1b0c00201df2429f2129f2129f2129f2129f2129f2129f211df310503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030
010c00000c073000030c623000000c673000030c073000030c623000000c623000030c6730000311600000030c073000030c623000000c673000030c073000030c653000000c0000c6530c600000030c65300003
010c000012f7012f700c62300000306250000300000186150c6230c61312f7012f703c62500003116003062512f7012f700c62300000306250000300000186150c6230c6130c623000033c625000031160030625
6d0c000000502005020656200502065720050206562005020656200502065620050217d6217d52000000000000502005020656200502065720050206562005020656200502065620050217d6217d520000000000
bb0c000000500005001e560185001c570185001e560005001c560185001e560005001756017550000000000000500005001e560185001c570185001e560005001c560185001e5600050017560175500000000000
c10c00001254012540125401254012540125401254012540125301253012530125301253012530125301253012520125201252012520125201252012520125201251012510125101251012510125101251012510
c10c00000d5400d5400d5400d5400d5400d5400d5400d5400d5300d5300d5300d5300d5300d5300d5300d5300d5200d5200d5200d5200d5200d5200d5200d5200f5400f5400f5400f5400f5300f5300f5300f530
010c00100000000000000000000000000000000000000000000000000000000000002a0102a014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d0c000000502005020657200502065720050206572005020657200502065720000006572000000656200000065720000006575065750657200000065720000017d6217d6217d6217d6517d6217d6217d6217d65
6d0c000000502005020657200502065720050206572005020657200502065720000006572000000656200000065720000006572065000657200000065720000017d6217d6217d6217d6517d6217d6217d6217d65
bb0c000000502005021e572185021e572185021e572185021e572185021e572180001e572180001e562180001e572180001e5751e5751e572180001e572180001756217562175621756517562175621756217565
bb0c00001e572005021e572185021e572185021e572185021e572185021e572180001e572180001e572180001e572180001e5721e5001e572180001e572180001756217562175621756517562175621756217565
010c000012f5012f5012f5012f5012f5012f5012f5012f5017f5017f5017f5017f5017f5017f5017f5017f501ef501ef501ef501ef501ef501ef501ef501ef5017f5017f5017f5017f5017f5017f5017f5017f50
010c000012f7012f700c62300000306250000300000186150c6230c61312f7012f703c62500003116003062512f7012f700c6230c623306250c6230c62318615306250c600000033062500003116003062500000
390c00001e5141e5101e5101e5101e5101e5101e5101e515175141751017510175101751017510175101751519514195101951019510195101951019510195151c5141c5101c5101c5101c5101c5101c5101c515
390c00001951419510195101951019510195101951019515175141751017510175101751017510175101751514514145101451014510145101451014510145151251412510125101251012510125101251012515
010c000012f7012f700c62300000306250000300000186150c6230c61312f7012f703c62500003116003062512f7012f700c62300000306250000300000186151ef701ef701ef701ef701cf701cf701af701af70
010c000013f7013f700c62300000306250000300000186150c6230c61313f7013f703c62500003116003062513f7013f700c6230c623306250c6230c623186151ef701ef701ef701ef701cf701cf701af701af70
010c000012f5012f5012f5012f5012f5012f5012f5012f5017f5017f5017f5017f5017f5017f5017f5017f501ef501ef501ef501ef501ef501ef501ef501ef5017f5017f5017f5017f5017f4017f4017f3017f30
6d0c00000050200502125720050206572005020657200502065720050206575065750657206562005020050200502005021757200502065720050206572005020657200502065750657506572065620050200502
bb0c00001e500005021e572185021c572185021e572185021c572185021e5751e575175721755217572180001e500180001e5721e5001c572180001e572180001c572185021e5751e57517572175521757217500
bb0c000021562215622156221562215622156521562215651e5721e5721e572000001e5721e5721e572000001e572000001e572000001c572180001e57218000175721757217572175721e500180001c50018500
bb0c000021562215622156221562215622156521562215651e5721e5721e572000001e5721e5721e572000001e572000001e572000001c572180001e572180001f572000001e572000001c572000001e5721e500
bb0c00001e500005021e572185021c572185021e572185021c572185021e5751e575175721755217572180001e500180001e5721e5001c572180001e572180001f572185021e5751e5751c5721c5521c57217500
000c00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 0a424344
01 04420844
00 04420844
00 04424909
00 0b424909
00 0c0f0d11
00 1a100d11
00 0c0f180e
00 1b10190e
00 0416124e
00 0416134e
00 04165214
00 0b1c5215
00 0c0f1d11
00 1a101d11
00 0c0f181e
00 1b101921
00 0c0f1d1f
00 1a101d20
00 0c0f181e
00 1b101921
00 04161218
00 04161319
00 04161814
00 0b1c1915
00 22424344

